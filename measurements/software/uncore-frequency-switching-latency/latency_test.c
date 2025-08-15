/*   Test program that triggers uncore frequency switches
 *
 *    Copyright (C) 2019  TU Dresden
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#define _GNU_SOURCE 1

#include <asm/unistd.h>
#include <fcntl.h>

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// This buffer must fit into the L1d Cache, therefore it should be a lot smaller
// than the cache itself
#define L1_DATA_SIZE 16 * 1024
// This buffer must not fit into the L2 Cache
#define L3_DATA_SIZE 4 * 1024 * 1024
#define CACHE_LINE 64
#define RAND_NUM 1234567
#define MAX_CYCLES 2000

/**
 * Returns time stamp counter
 */
static __inline__ uint64_t rdtsc(void) {
  uint32_t a, d;
  asm volatile("rdtsc" : "=a"(a), "=d"(d));
  return (uint64_t)a | (uint64_t)d << 32;
}

typedef void **test_buffer_t;

/**
 * Create a buffer for pointer chasing
 */

test_buffer_t create_buffer(size_t size) {
  void **buffer = malloc(size);
  size_t nr_elements = (size / sizeof(void *));
  // only use every nth element (cache line)
  size_t sep_elements = CACHE_LINE / sizeof(void *);
  size_t nr_used_elements = nr_elements / sep_elements;
  void **list = malloc(nr_used_elements * sizeof(void *));
  for (size_t i = 0; i < nr_used_elements - 1; i++)
    list[i] = (void *)&buffer[(i + 1) * sep_elements];
  srand(RAND_NUM);
  void **current = buffer;
  size_t nr = 0;
  size_t max = nr_used_elements - 1;
  for (size_t i = 0; i < nr_used_elements - 1; i++) {
    int r = rand() % max;
    // set target for jump
    *current = list[r];
    // set new current
    current = list[r];
    // remove list[r] from list
    // end of list: nr_used_elements-1-(i-1)
    for (size_t j = r; j < max - 1; j++)
      list[j] = list[j + 1];
    max--;
    nr++;
  }
  *current = buffer;
  free(list);
  return buffer;
}

/**
 * Jump around nr_accesses times in pointer chasing buffer
 */

static __inline__ test_buffer_t run_buffer_plain(test_buffer_t buffer,
                                                 size_t nr_accesses) {
  size_t nr = 0;
  void *current = (void *)buffer;
  while (nr < nr_accesses) {
    current = (*(void **)current);
    nr++;
  }
  return current;
}

/**
 * Follow the pointer chasing buffer by loading the new address from the buffer.
 * \arg buffer The pointer to the buffer of pointers
 * \arg nr_accesses The total number of accesses of the buffer
 * \arg max_cycles The load latency threshold value used to detect that the
 * frequency changed
 * \arg before The average load latency in cyles before the frequency change
 * occured
 * \arg change The number of cycles before the frequency change occured
 * \arg duration The duration of the load above the max_cycles theshold
 * \arg after The average load latency in cycles after the frequency change
 * \returns The last used pointer of the buffer of pointers
 */
static __inline__ test_buffer_t
run_buffer(test_buffer_t buffer, size_t nr_accesses, uint64_t max_cycles,
           uint64_t *before, uint64_t *change, uint64_t *duration,
           uint64_t *after) {
  *before = 0;
  *change = 0;
  *duration = 0;
  *after = 0;

  void *current = (void *)*buffer;
  const uint64_t start_timestamp = rdtsc();

  // the timestamp after the last load
  uint64_t last_timestamp = start_timestamp;
  // the timestamp after the current load
  uint64_t current_timestamp;
  bool frequency_change_detected = false;
  uint64_t timestamp_at_gap, timestamp_before_gap, nb_of_accesses_before_gap;

  for (size_t nr = 0; nr < nr_accesses;
       nr++, last_timestamp = current_timestamp) {
    // Read the pointer chaser and measure the timestamp after the load
    current = (*(void **)current);
    current_timestamp = rdtsc();

    if ((!frequency_change_detected) &&
        (current_timestamp - last_timestamp > max_cycles)) {
      timestamp_at_gap = current_timestamp;
      timestamp_before_gap = last_timestamp;

      nb_of_accesses_before_gap = nr;
      *before =
          (timestamp_before_gap - start_timestamp) / nb_of_accesses_before_gap;
      *duration = timestamp_at_gap - timestamp_before_gap;

      frequency_change_detected = true;
    }
  }

  if (frequency_change_detected) {
    *after = (current_timestamp - timestamp_at_gap) /
             (nr_accesses - nb_of_accesses_before_gap);
    *change = timestamp_before_gap - start_timestamp;
  }
  return current;
}

/**
 * Return the number of 100kHz uncore steps that are inside the range of
 * default_uncore_range.
 */
size_t getNumberOfUncoreStepIn100KHzSteps(const uint64_t default_uncore_range) {
  const uint8_t start = (default_uncore_range >> 8) & 0xff;
  const uint8_t stop = default_uncore_range & 0xff;

  assert((start <= stop) &&
         "Given uncore start value is not smaller equal to the stop value.");

  return stop - start + 1;
}

/**
 * Fill the buffer provided with fixed uncore frequencies in 100kHz steps from
 * the range defined with default_uncore_range.
 */
void fillFixedUncoreFrequenciesBuffer(uint64_t *buffer,
                                      const uint64_t default_uncore_range) {
  assert(buffer && "Buffer not provided.");

  const uint8_t start = (default_uncore_range >> 8) & 0xff;
  const uint8_t stop = default_uncore_range & 0xff;

  for (uint8_t freq = start; freq <= stop; freq++) {
    buffer[freq - start] = (freq << 8) | freq;
  }
}

int main() {
  // open fd for switching msr
  int msr_fd = open("/dev/cpu/0/msr", O_RDWR);
  // report it, should be > 0 ;)
  printf("fd=%d\n", msr_fd);

  // Read the current uncore frequency setting
  uint64_t default_uncore_range;
  pread(msr_fd, &default_uncore_range, sizeof(default_uncore_range), 0x620);

  // tested UFS frequencies
  uint64_t *settings =
      malloc(getNumberOfUncoreStepIn100KHzSteps(default_uncore_range) *
             sizeof(uint64_t));
  fillFixedUncoreFrequenciesBuffer(settings, default_uncore_range);

  // create pointer chasing buffers
  test_buffer_t l1_buffer = create_buffer(L1_DATA_SIZE);

  test_buffer_t l3_buffer = create_buffer(L3_DATA_SIZE);

  // nr of accesses for pointer chasing
  size_t nr = 100000;

  // gathered results
  uint64_t performance_before, performance_after, cycles_switch,
      cycles_duration;

#ifdef MANUAL_FREQUENCY_LATENCY
  // for each source target combination:
  for (uint64_t source = 0;
       source < getNumberOfUncoreStepIn100KHzSteps(default_uncore_range);
       source++) {
    for (uint64_t target = 0;
         target < getNumberOfUncoreStepIn100KHzSteps(default_uncore_range);
         target++) {
      if (source == target) {
        continue;
      }
      // repeat measurement 1000 times
      for (int i = 0; i < 1000; i++) {
        // set default
        pwrite(msr_fd, &settings[source], sizeof(settings[source]), 0x620);

        // run in default
        l3_buffer =
            run_buffer(l3_buffer, nr, MAX_CYCLES, &performance_before,
                       &cycles_switch, &cycles_duration, &performance_after);
        /*                printf(
                                "default %d00 MHz->%d00Mhz Cycles per access
           before:%lu after:%lu, switch after %lu cycles, took %lu cycles\n",
                                0xFF & settings[source], 0xFF &
           settings[target], performance_before, performance_after,
           cycles_switch, cycles_duration);
        */
        // switch to target and measure
        pwrite(msr_fd, &settings[target], sizeof(settings[target]), 0x620);
        l3_buffer =
            run_buffer(l3_buffer, nr, MAX_CYCLES, &performance_before,
                       &cycles_switch, &cycles_duration, &performance_after);
        printf("%lu00 MHz->%lu00Mhz Cycles per access before:%lu after:%lu, "
               "switch after %lu cycles, took %lu cycles\n",
               0xFF & settings[source], 0xFF & settings[target],
               performance_before, performance_after, cycles_switch,
               cycles_duration);
      }
    }
  }
#endif

  // set default again
  pwrite(msr_fd, &default_uncore_range, sizeof(default_uncore_range), 0x620);

#ifdef AUTOMATIC_FREQUENCY_LATENCY
  for (int i = 0; i < 1000; i++) {
    // first train for local access (L1)
    l1_buffer =
        run_buffer(l1_buffer, nr * 10000, MAX_CYCLES, &performance_before,
                   &cycles_switch, &cycles_duration, &performance_after);
    // then: go to offcore (L3)
    l3_buffer =
        run_buffer(l3_buffer, nr * 1000, MAX_CYCLES, &performance_before,
                   &cycles_switch, &cycles_duration, &performance_after);
    // then: report performance stuff :)
    printf("L1->L3 Cycles per access before:%lu after:%lu, switch after %lu "
           "cycles, took %lu cycles\n",
           performance_before, performance_after, cycles_switch,
           cycles_duration);
  }
#endif

  // set default again
  pwrite(msr_fd, &default_uncore_range, sizeof(default_uncore_range), 0x620);

  return EXIT_SUCCESS;
}
