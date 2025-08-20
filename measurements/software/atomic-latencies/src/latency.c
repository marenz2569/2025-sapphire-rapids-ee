/*
 * Low-level Latency Measurements
 * Copyright (C) 2025 TU Dresden, ZIH
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define _GNU_SOURCE

#include <pthread.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
// need uint64_t
#include <errno.h>
#include <limits.h>
#include <stdint.h>

// include the architecture specific functions
#if defined __x86_64__
#include "x86.c"
#elif defined __aarch64__
#include "aarch64.c"
#endif

static int DO_NOT_USE;
static void *ERROR = &DO_NOT_USE; // Error code for invalid arguments

struct function_arguments {
  /* on which CPUs should the threads be placed (first placement allocates and
   * initializes data) */
  uint64_t *thread_locations;
  /* size of thread_locations */
  int64_t num_thread_locations;
  /* number of iterations for single measurement */
  int64_t num_iterations;
  /* number of cache lines measured */
  int64_t num_cache_lines;
  /* size of a cache line */
  int64_t cache_line_size;
  /* number of measurements */
  int64_t num_repetitions;

  /* an array that will be accessed for flush and cmpxchg measurements, size
   * will be num_cache_lines * cache_line_size */
  char *cache_line_ptr;
  /* token for first threads cmpxchg */
  int token;
  /* token for second threads cmpxchg */
  int other_token;
};

void *pin_to_cpu(uint64_t current_location) {
  // set the affinity of the current thread to the current location
  cpu_set_t cpuset;
  CPU_ZERO(&cpuset);
  CPU_SET(current_location, &cpuset);
  if (sched_setaffinity(0, sizeof(cpu_set_t), &cpuset) != 0) {
    char error_buffer[256];
    if (strerror_r(errno, error_buffer, sizeof(error_buffer)) == 0) {
      fprintf(stderr, "Failed to set thread affinity (%s)\n", error_buffer);
    } else {
      fprintf(stderr, "Failed to set thread affinity\n");
    }
    return ERROR; // Error code for setting thread affinity failure
  }
  return NULL; // Indicate successful completion of the pinning
}

void *latency_routine(void *args_void) {
  struct function_arguments *args = (struct function_arguments *)args_void;
  if (args == NULL) {
    fprintf(stderr, "Invalid arguments provided to latency_routine.\n");
    return ERROR; // Error code for invalid arguments
  }
  // we go through all thread locations and measure the latency
  // while one thread (token == 0) is increasing its responsible location
  // slowly, the other one (token == 1) is doing this all the time. if both are
  // on the same location, we do not measure anything

  if (args->num_thread_locations <= 0 || args->num_cache_lines <= 0 ||
      args->cache_line_size <= 0 || args->cache_line_ptr == NULL) {
    fprintf(stderr, "Invalid parameters in function arguments.\n");
    return ERROR; // Error code for invalid parameters
  }

  // ensure that the cache line pointer is aligned to the cache line size
  if ((uintptr_t)args->cache_line_ptr % args->cache_line_size != 0) {
    fprintf(stderr,
            "Cache line pointer is not aligned to the cache line size.\n");
    return ERROR; // Error code for unaligned cache line pointer
  }

  // parent allocates zeroed memory for latency results (i.e. for each
  // combination of thread_locations, thread_locations and cache lines)
  uint64_t *flush_results = NULL;
  uint64_t *latency_results = NULL;
  uint64_t *count_results = NULL;
  FILE *file = NULL;
  FILE *flush_file = NULL;
  if (args->token == 0) {

    latency_results = malloc(
        args->num_thread_locations * args->num_thread_locations *
        args->num_cache_lines * args->num_repetitions * sizeof(uint64_t));
    if (latency_results == NULL) {
      fprintf(stderr, "Could not allocate memory for latency results\n");
      return ERROR;
    }

    count_results = malloc(args->num_thread_locations *
                           args->num_thread_locations * args->num_cache_lines *
                           args->num_repetitions * sizeof(uint64_t));
    if (count_results == NULL) {
      free(latency_results);
      fprintf(stderr, "Could not allocate memory for count results\n");
      return ERROR;
    }

    flush_results = malloc(args->num_thread_locations * args->num_cache_lines *
                           args->num_repetitions * sizeof(uint64_t));
    if (flush_results == NULL) {
      free(latency_results);
      free(count_results);
      fprintf(stderr, "Could not allocate memory for flush results\n");
      return ERROR;
    }

    memset(latency_results, 0,
           args->num_thread_locations * args->num_thread_locations *
               args->num_cache_lines * args->num_repetitions *
               sizeof(uint64_t));
    memset(count_results, 0,
           args->num_thread_locations * args->num_thread_locations *
               args->num_cache_lines * args->num_repetitions *
               sizeof(uint64_t));
    memset(flush_results, 0,
           args->num_thread_locations * args->num_cache_lines *
               args->num_repetitions * sizeof(uint64_t));

    // now store the latency results in a file
    file = fopen("latency_results.txt", "w");
    if (file == NULL) {
      perror("Failed to open latency results file");
      free(latency_results);
      free(count_results);
      free(flush_results);
      return ERROR; // Error code for file opening failure TODO: cleanup
    }

    flush_file = fopen("flush_results.txt", "w");
    if (flush_file == NULL) {
      perror("Failed to open flush results file");
      free(latency_results);
      free(count_results);
      free(flush_results);
      return ERROR; // Error code for file opening failure TODO: cleanup
    }
  }

  int token = args->token;
  int other_token = args->other_token;

  // now measure the latency for each combination of thread locations and cache
  // lines
  for (int i = 0; i < args->num_thread_locations; i++) {
    if (token == 0) {
      if (pin_to_cpu(args->thread_locations[i]) == ERROR) {
        free(latency_results);
        free(count_results);
        free(flush_results);
        fclose(file);
        fclose(flush_file);
        return ERROR; // Error code for pinning failure
      }

      // sleep for 100 ms to flush caches
      //            usleep(10000); // 10 ms

      // flush the cache lines for each thread location
      for (long long int r = 0; r < args->num_repetitions; r++) {
        for (long long int cl = 0; cl < args->num_cache_lines; cl++) {
          char *cache_line =
              args->cache_line_ptr + (cl * args->cache_line_size);
          uint64_t start, stop;
          TIMER(start);
          FLUSHADDRESS(cache_line, args->num_iterations);
          TIMER(stop);
          flush_results[(i * args->num_repetitions + r) *
                            args->num_cache_lines +
                        cl] = (stop - start);
        }
      }
    }

    for (int j = 0; j < args->num_thread_locations; j++) {
      if (args->thread_locations[i] == args->thread_locations[j]) {
        // skip the measurement if both threads are on the same location
        continue;
      }
      if (token != 0) {
        if (pin_to_cpu(args->thread_locations[i]) == ERROR) {
          free(latency_results);
          free(count_results);
          free(flush_results);
          fclose(file);
          fclose(flush_file);
          return ERROR; // Error code for pinning failure
        }
      }

      // sleep for 100 ms to flush caches
      //            usleep(10000); // 10 ms

      for (long long int r = 0; r < args->num_repetitions; r++) {
        // now we go through the cache lines and repeat the measurements for
        // each cache line
        for (long long int k = 0; k < args->num_cache_lines; k++) {
          // access the cache line
          char *cache_line = args->cache_line_ptr + (k * args->cache_line_size);
          uint64_t start, stop;
          uint64_t count = 0;
          TIMER(start);
          // now we will use the cache line so that each thread atomically
          // conditionally writes its token to it as soon as the other token is
          // visible
          PING_PONG_CMP_XCHG(cache_line, other_token, token,
                             args->num_iterations, count);
          TIMER(stop);
          if (token == 0) {
            latency_results[((i * args->num_thread_locations + j) *
                                 args->num_repetitions +
                             r) *
                                args->num_cache_lines +
                            k] = (stop - start);
            count_results[((i * args->num_thread_locations + j) *
                               args->num_repetitions +
                           r) *
                              args->num_cache_lines +
                          k] = count;
          }
        }
      }
    }
  }
  if (args->token == 0) {

    // write the header
    fprintf(file, "Thread Location 1,Thread Location 2,Repetition,Cache "
                  "Line,Latency,Repetitions Set,Number Atomic CmpXchg\n");
    // write the latency results
    for (int i = 0; i < args->num_thread_locations; i++) {
      for (int j = 0; j < args->num_thread_locations; j++) {
        for (int r = 0; r < args->num_repetitions; r++) {
          for (int k = 0; k < args->num_cache_lines; k++) {
            fprintf(file, "%lu,%lu,%d,%d,%lu,%lu,%lu\n",
                    args->thread_locations[i], args->thread_locations[j], r, k,
                    latency_results[((i * args->num_thread_locations + j) *
                                         args->num_repetitions +
                                     r) *
                                        args->num_cache_lines +
                                    k],
                    args->num_iterations,
                    count_results[((i * args->num_thread_locations + j) *
                                       args->num_repetitions +
                                   r) *
                                      args->num_cache_lines +
                                  k]);
          }
        }
      }
    }
    // write the header
    fprintf(
        flush_file,
        "Thread Location,Repetition,Cache Line,Flush Time,Repetitions Set\n");
    // write the flush results
    for (int i = 0; i < args->num_thread_locations; i++) {
      for (int r = 0; r < args->num_repetitions; r++) {
        for (int j = 0; j < args->num_cache_lines; j++) {
          fprintf(flush_file, "%lu,%d,%d,%lu,%lu\n", args->thread_locations[i],
                  r, j,
                  flush_results[(i * args->num_repetitions + r) *
                                    args->num_cache_lines +
                                j],
                  args->num_iterations);
        }
      }
    }

    free(latency_results);
    free(count_results);
    free(flush_results);
    // close the files
    fclose(file);
    fclose(flush_file);
    printf("Latency results written to latency_results.txt and flush results "
           "written to flush_results.txt\n");
  }
  return NULL; // Indicate successful completion of the thread routine
}

int main(int argc, char *argv[]) {
  // arguments: // 1. locations of threads, 2. number of iterations, 3. number
  // of cache lines, 4. size of cache line, 5. number of repetitions example:
  // ./latency 0,1,5-6 10000 10 128 11
  if (argc < 6) {
    printf(
        "Low-level Latency Measurements  Copyright (C) 2025  TU Dresden, ZIH\n"
        "This program comes with ABSOLUTELY NO WARRANTY; for details type "
        "`show w'.\n"
        "This is free software, and you are welcome to redistribute it\n"
        "under certain conditions; type `show c' for details.");
    fprintf(stderr,
            "Usage: %s <thread_locations> <num_iterations_per_measurements> "
            "<number_of_cache_lines> <size_of_cache_line> <num_measurements>\n",
            argv[0]);
    return EXIT_FAILURE;
  }
  char *thread_locations = argv[1];
  long long int num_iterations = atoll(argv[2]);
  long long int num_cache_lines = atoll(argv[3]);
  long long int cache_line_size = atoll(argv[4]);
  long long int num_repetitions = atoll(argv[5]);

  // validate the input arguments
  if (thread_locations == NULL || strlen(thread_locations) == 0) {
    fprintf(stderr, "Thread locations must be a non-empty string.\n");
    return EXIT_FAILURE;
  }
  if (num_iterations <= 0) {
    fprintf(stderr, "Number of iterations must be a positive integer.\n");
    return EXIT_FAILURE;
  }
  if (num_cache_lines <= 0) {
    fprintf(stderr, "Number of cache lines must be a positive integer.\n");
    return EXIT_FAILURE;
  }
  if (cache_line_size <= 0) {
    fprintf(stderr, "Size of cache line must be a positive integer.\n");
    return EXIT_FAILURE;
  }
  if (num_repetitions <= 0) {
    fprintf(stderr, "Number of repetitions must be a positive integer.\n");
    return EXIT_FAILURE;
  }
  // parse the thread locations
  int num_threads = 0;
  // First, count the number of CPUs
  const char *loc_str = argv[1];
  char *saveptr;
  char *loc_copy = strdup(loc_str);
  char *token = strtok_r(loc_copy, ",", &saveptr);
  while (token) {
    int start, end;
    if (sscanf(token, "%d-%d", &start, &end) == 2) {
      if (start < 0 || end < start) {
        fprintf(stderr, "Invalid thread location range: %s\n", token);
        free(loc_copy);
        return EXIT_FAILURE;
      }
      num_threads += (end - start + 1);
    } else if (sscanf(token, "%d", &start) == 1) {
      if (start < 0) {
        fprintf(stderr, "Invalid thread location: %s\n", token);
        free(loc_copy);
        return EXIT_FAILURE;
      }
      num_threads++;
    } else {
      fprintf(stderr, "Invalid thread location: %s\n", token);
      free(loc_copy);
      return EXIT_FAILURE;
    }
    token = strtok_r(NULL, ",", &saveptr);
  }
  free(loc_copy);

  if (num_threads <= 0) {
    fprintf(stderr, "No valid thread locations provided.\n");
    return EXIT_FAILURE;
  }

  // Now, fill the array with CPU IDs
  uint64_t *thread_locations_exact = malloc(num_threads * sizeof(uint64_t));
  if (!thread_locations_exact) {
    perror("Failed to allocate memory for thread locations array");
    return EXIT_FAILURE;
  }
  int index = 0;
  loc_copy = strdup(loc_str);
  if (!loc_copy) {
    perror("Failed to allocate memory for thread locations copy");
    free(thread_locations_exact);
    return EXIT_FAILURE;
  }
  token = strtok_r(loc_copy, ",", &saveptr);
  while (token) {
    int start, end;
    if (sscanf(token, "%d-%d", &start, &end) == 2) {
      for (int i = start; i <= end; ++i) {
        thread_locations_exact[index++] = i;
      }
    } else if (sscanf(token, "%d", &start) == 1) {
      thread_locations_exact[index++] = start;
    }
    token = strtok_r(NULL, ",", &saveptr);
  }
  free(loc_copy);

  // allocat cache lines
  char *cache_lines =
      aligned_alloc(cache_line_size, num_cache_lines * cache_line_size);
  if (cache_lines == NULL) {
    perror("Failed to allocate memory for cache lines");
    return EXIT_FAILURE;
  }
  // initialize cache lines
  memset(cache_lines, 0, num_cache_lines * cache_line_size);

  struct function_arguments args_parent = {.thread_locations =
                                               thread_locations_exact,
                                           .num_thread_locations = num_threads,
                                           .num_iterations = num_iterations,
                                           .num_cache_lines = num_cache_lines,
                                           .cache_line_size = cache_line_size,
                                           .num_repetitions = num_repetitions,
                                           .cache_line_ptr = cache_lines,
                                           .token = 0,
                                           .other_token = 1};

  struct function_arguments args_child = {.thread_locations =
                                              thread_locations_exact,
                                          .num_thread_locations = num_threads,
                                          .num_iterations = num_iterations,
                                          .num_cache_lines = num_cache_lines,
                                          .cache_line_size = cache_line_size,
                                          .num_repetitions = num_repetitions,
                                          .cache_line_ptr = cache_lines,
                                          .token = 1,
                                          .other_token = 0};

  // create a child thread
  pthread_t child;
  if (pthread_create(&child, NULL, latency_routine, &args_child) != 0) {
    perror("Failed to create child thread");
    return EXIT_FAILURE;
  }
  latency_routine(&args_parent);
  // wait for the child thread to finish
  if (pthread_join(child, NULL) != 0) {
    perror("Failed to join child thread");
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
