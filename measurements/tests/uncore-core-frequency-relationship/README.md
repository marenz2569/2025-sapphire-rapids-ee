# Test for Uncore frequency changes

These scripts in this folder test the uncore frequency behavior by evaluating the relationship between the core and uncore frequencies.

## Uncore - core frequency relationship

### Precondition

The `acpi_cpufreq` or `intel-cpufrq` drivers must be used for these tests. Please check `/sys/devices/system/cpu/cpu*/cpufreq/scaling_driver`. The script will terminate if another CPUFreq driver is used.
Access to `rdmsr` and `sudo` is assumed.
The script assumes an Intel Core i9-12900k. If you use a different CPU with different core counts and/or frequencies, the script must be adapted.

### Script test2/uncore_frequencies.sh

- Tests different permutations of core/uncore frequency pairings, including automatic frequency selection. For this purpose, the script will change the scheduling governor several times
- A `while(1);` workload is executed on one or more cores for a duration of 10 seconds
- C-states are enabled for all tests
- The core and uncore frequencies are measured at core 0 (p-core) and core 23 (e-core) using `perf stat` for the duration of the workload, with a sampling interval of 1 second

### Results

Results are presented in human readable output by the script. The configuration of each measurement is described in the output.

### Analysis

No additional steps for the analysis are required.

## License

"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing

This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.

## References

[1] Schöne, R., Ilsche, T., Bielert, M., Gocht, A., & Hackenberg, D. (2019, July). Energy efficiency features of the intel skylake-sp processor and their impact on performance. In 2019 International Conference on High Performance Computing & Simulation (HPCS) (pp. 399-406). IEEE.
[2] https://github.com/tud-zih-energy/2019-HPCS-Skylake-EE/tree/master/ufs-latencies
