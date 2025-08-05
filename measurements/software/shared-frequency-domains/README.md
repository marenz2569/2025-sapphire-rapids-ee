# Frequency dependency test

The scripts `test_active.sh` and `test_idle.sh` test whether cpus (as logical cores / hardware threads) influence each other's frequency.

## Precondition

C-states have to be enabled. These files should hold the value 0: `/sys/devices/system/cpu/cpu*/cpuidle/state*/disable`

## Script 1 test_idle.sh

- Tests under idle conditions
- All cores a set to a low frequency (800 MHz) in sysfs
- One of the cores is set to a high frequency (3800 MHz) in sysfs (`CPU2` in the script)
- If a CPU (`CPU2`) is said to influence another, setting its frequency in sysfs influences the frequency of the other CPU (`CPU1`) even if  `CPU1` is idling
- Each CPU is tested as an influencing CPU with a high frequency
- The frequency of the influenced core (`CPU1`) is measured using `perf stat`

## Script 1 test_active.sh

- Tests under active conditions
- All cores a set to a low frequency (800 MHz) in sysfs
- One of the cores is set to a high frequency (3800 MHz) in sysfs (`CPU2` in the script)
- If a CPU (`CPU2`) is said to influence another, setting its frequency in sysfs influences the frequency of the other CPU (`CPU1`) if `CPU1` is active (executing a `while(1);` loop)
- The frequency of the influenced core (`CPU1`) is measured using `perf stat`

## Results

The results for these tests are part of the output of the scripts.
The output is presented in this way:
```
$CPU2 influences $CPU1: $frequency_in_kHz
```

## License
"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing

This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.
