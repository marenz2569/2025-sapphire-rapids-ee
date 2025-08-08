# Test for idle switch times
This is the test that checks how long it needs to wake up a core. The methodology was introduced and described in [1,2].

## Precondition
- GCC (can be changed in the measurement script)
- The `intel_idle` driver, as defined in `/sys/devices/system/cpu/cpuidle/current_driver`
- The `acpi_cpufreq` driver, as defined in `/sys/devices/system/cpu/cpu*/cpufreq/scaling_driver`

## Scripts test/measure.sh
- gathers idle switch times for different combinations of frequency, idle state and placement of caller/callee


## Results
- have been tar-gz-ipped to test/out.perf.tar.gz to reduce file size.
- note: the resulting perf.data files have been converted using `perf script --ns` so that they will also be readable on other systems.

## Analysis
- use analyze/analyze.ipynb

## License
"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing

This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.

## References
[1] Ilsche, T., Schöne, R., Joram, P., Bielert, M., & Gocht, A. (2018, May). System monitoring with lo2s: Power and runtime impact of c-state transitions. In 2018 IEEE International Parallel and Distributed Processing Symposium Workshops (IPDPSW) (pp. 712-715). IEEE.
[2] https://github.com/tud-zih-energy/2021-rome-ee/tree/main/cstate

