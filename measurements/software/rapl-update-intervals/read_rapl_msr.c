/*
 * Copyright (C) 2024 TU Dresden, Center for Information Services and
 * High Performance Computing
 * Copyright (C) 2025 Markus Schmidl
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/\>.
 */

#include <assert.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/// Register Address: 611H, 1553 MSR_PKG_ENERGY_STATUS
/// PKG Energy Status (R/O)
/// See Section 16.10.3, “Package RAPL Domain.”
/// Package
#define MSR_PCKG_ENERGY 0x611

/// Register Address: 612H, 1554 MSR_PACKAGE_ENERGY_TIME_STATUS
/// Package energy consumed by the entire CPU (R/W) Package
/// 31:0 Total amount of energy consumed since last reset.
/// 63:32 Total time elapsed when the energy was last updated. This is a
/// monotonic increment counter with auto wrap back to zero after overflow. Unit
/// is 10ns.
#define MSR_PACKAGE_ENERGY_TIME_STATUS 0x612

/// Register Address: 619H, 1561 MSR_DRAM_ENERGY_STATUS
/// Energy in 61 micro-joules. Requires BIOS configuration to enable DRAM
/// RAPL mode 0 (Direct VR).
#define MSR_RAM_ENERGY 0x619

/// Register Address: 639H, 1593 MSR_PP0_ENERGY_STATUS
/// PP0 Energy Status (R/O)
/// See Section 16.10.4, “PP0/PP1 RAPL Domains.”
/// Package
#define MSR_PP0_ENERGY 0x639

/// Register Address: 641H, 1601 MSR_PP1_ENERGY_STATUS
/// PP1 Energy Status (R/O)
/// See Section 16.10.4, “PP0/PP1 RAPL Domains.”
/// Package
#define MSR_PP1_ENERGY 0x641

/// Register Address: 64DH, 1613 MSR_PLATFORM_ENERGY_STATUS
/// Platform Energy Status (R/O) Package
/// 31:0 TOTAL_ENERGY_CONSUMED
/// Total energy consumption in J (32.0), in 10nsec units.
/// 63:32 TIME_STAMP
/// Time stamp (U32.0).
#define MSR_PLATFORM_ENERGY_STATUS 0x64D

/// Struct that contains the RAPL Energy register values and the timestamp of
/// the read.
struct RaplEnergyTimeValue {
  /// The value of the timestamp counter when the values was read
  uint64_t timestamp;
  struct Value {
    /// The energy value in the MSR.
    uint32_t value;
    /// The timestamp value in the MSR. This may be a reservered field.
    uint32_t timestamp_rapl;
  } value;
};

/// Return the current timestamp
static inline uint64_t rdtsc() {
  uint64_t rax, rdx;
  asm volatile("rdtsc" : "=a"(rax), "=d"(rdx)::);
  return (rdx << 32) | rax;
}

/// Read rapl energy MSR values for an array of registers and timestamp it.
/// \arg fd The file descriptor the the MSR handle
/// \arg read_val The array of values that are read from the MSR handle.
/// \arg registers The array of registers that are read.
/// \arg len The length of the read_val and registers array.
void read_msr(const int fd, struct RaplEnergyTimeValue *read_val,
              const uint64_t *const registers, const size_t len) {
  for (size_t i = 0; i < len; i++) {
    read_val[i].timestamp = rdtsc();
    // We do not assert when reading nothing, as this will not cause a change in
    // the behaviour of our program.
    (void)pread(fd, &read_val[i].value, sizeof(uint64_t), registers[i]);
  }
}

/// Check if any register value in an array of previous and current values have
/// changed.
/// \arg previous_values The array of previous values
/// \arg previous_values The array of current values
/// \arg len The size of both arrays
/// \returns True if for any element in both arrays the read content has
/// changed.
bool any_value_changed(const struct RaplEnergyTimeValue *const previous_values,
                       const struct RaplEnergyTimeValue *const current_values,
                       const size_t len) {
  bool any_changed = false;

  for (size_t i = 0; i < len; i++) {
    if (0 != memcmp(&previous_values[i].value, &current_values[i].value,
                    sizeof(uint64_t))) {
      any_changed = true;
    }
  }

  return any_changed;
}

int main() {
  uint64_t registers[] = {MSR_PCKG_ENERGY, MSR_PACKAGE_ENERGY_TIME_STATUS,
                          MSR_RAM_ENERGY,  MSR_PP0_ENERGY,
                          MSR_PP1_ENERGY,  MSR_PLATFORM_ENERGY_STATUS};

  const size_t len = sizeof(registers) / sizeof(*registers);

  struct RaplEnergyTimeValue previous_values[len];
  struct RaplEnergyTimeValue current_values[len];

  memset(previous_values, 0, sizeof(struct RaplEnergyTimeValue) * len);
  memset(current_values, 0, sizeof(struct RaplEnergyTimeValue) * len);

  int fd = open("/dev/cpu/0/msr", O_RDONLY);
  assert(fd >= 0);

  printf("register,previous_timestamp,previous_value,previous_timestamp_"
         "rapl,current_timestamp,current_value,current_timestamp_rapl\n");

  for (;;) {
    read_msr(fd, current_values, registers, len);

    // Print all if any changed
    if (any_value_changed(previous_values, current_values, len)) {
      for (size_t i = 0; i < len; i++) {
        printf("%lu,%lu,%u,%u,%lu,%u,%u\n", registers[i],
               previous_values[i].timestamp, previous_values[i].value.value,
               previous_values[i].value.timestamp_rapl,
               current_values[i].timestamp, current_values[i].value.value,
               current_values[i].value.timestamp_rapl);
      }
    }

    memcpy(previous_values, current_values,
           sizeof(struct RaplEnergyTimeValue) * len);
  }

  return EXIT_SUCCESS;
}