#!/bin/sh

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

gcc while_true.c -o while_true

echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable

#set low frequency on all CPUs
echo userspace | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# for all 24 CPUs
CPUS=`seq 0 23`

for CPU1 in $CPUS; do
  for CPU2 in $CPUS; do
  #set low frequency on all CPUs
    echo 800000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed > /dev/null
  #set high frequency on the influential CPU
    echo 2400000 | sudo tee /sys/devices/system/cpu/cpu${CPU2}/cpufreq/scaling_setspeed > /dev/null
  #explicitly set tested CPU to low frequency
    echo 800000 | sudo tee /sys/devices/system/cpu/cpu${CPU1}/cpufreq/scaling_setspeed > /dev/null
    #test frequency on tested CPU via perf
    FREQ=`taskset -c ${CPU1} perf stat --log-fd 1 -e cycles -x ' ' timeout 1s ./while_true | grep -v "not counted" - | awk '{print $1}' `
    #it should be 800 MHz
    if [ $FREQ -gt 1400000000 ]; then
      echo "$CPU2 influences $CPU1: $FREQ"
    fi
    sleep 1
  done
done
