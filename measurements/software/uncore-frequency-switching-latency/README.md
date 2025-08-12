# Uncore Frequency Scaling Test
Test for getting the uncore frequency switching latencies.

## Compilation
Requirements:
- GCC compiler

You should look into the code and change the tested uncore frequencies (we used the ones available at our system)

```gcc latency_test.c -o latency_test```

## Run

Requirements
* The program should run at CPU 0 (you can change the source code if you want to change the used MSRs)
* The kernel module msr should be loaded (`sudo modprobe msr`)
* You need root access

```sudo taskset -c 0 ./latency_test > result.log```

The resulting log should include the time that a switch needs and the average performance before and after the switch

## License
"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing

This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.

