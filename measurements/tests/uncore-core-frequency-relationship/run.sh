#! /usr/bin/env bash

# "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
# Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing
#
# This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.
#
# The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.

# set core frequencies
# parameters: $1: min frequency in kHz, $2: max frequency in kHz
setFrequency () {
    echo -n "$1" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
    echo -n "$2" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
}

# 1) workload on p-core
# 1.1) turbo enabled,  performance governor, automatic uncore frequency selection in full range
# 1.2) turbo disabled, performance governor, 2.0 GHz core frequency, automatic uncore frequency selection in full range
# 1.3) turbo disabled, performance governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
# 1.4) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
# 1.5) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 2.5 GHz
# 1.6) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 0.8 GHz
# 1.7) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.0 GHz
# 1.8) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.5 GHz

section_begin="\n######## "
section_end=" ########"

# 1) workload on p-core
echo -e "${section_begin}1) workload on p-core${section_end}"

# 1.1) turbo enabled,  performance governor, automatic uncore frequency selection in full range
echo -e "${section_begin}1.1) turbo enabled,  performance governor, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 3800000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.1.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.1.uncore.log 2> /dev/null
wait

# 1.2) turbo disabled, performance governor, 2.0 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.2) turbo disabled, performance governor, 2.0 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.2.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.2.uncore.log 2> /dev/null
wait

# 1.3) turbo disabled, performance governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.3) turbo disabled, performance governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.3.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.3.uncore.log 2> /dev/null
wait

# 1.4) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.4) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x0808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.4.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.4.uncore.log 2> /dev/null
wait

# 1.5) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 2.5 GHz
echo -e "${section_begin}1.5) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 2.5 GHz${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x1919

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.5.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.5.uncore.log 2> /dev/null
wait

# 1.6) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.6) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x0808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.6.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.6.uncore.log 2> /dev/null
wait

# 1.7) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.0 GHz
echo -e  "${section_begin}1.7) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.0 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x1414

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.7.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.7.uncore.log 2> /dev/null
wait

# 1.8) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.5 GHz
echo -e "${section_begin}1.8) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.5 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x1919

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o $RESULTS_FOLDER/1.8.perf.log taskset -c 0 timeout 10s $WHILE_TRUE &
sudo $IUFD --outfile $RESULTS_FOLDER/1.8.uncore.log 2> /dev/null
wait

sudo wrmsr 0x620 0x0819