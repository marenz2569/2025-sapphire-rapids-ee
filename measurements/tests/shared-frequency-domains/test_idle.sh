#!/usr/bin/env bash

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

echo off | sudo tee /sys/devices/system/cpu/smt/control > /dev/null

# for all 56 CPUs
CPUS=`seq 0 55`

for CPU1 in $CPUS; do
  for CPU2 in $CPUS; do
    if [[ $CPU1 -eq $CPU2 ]];
    then
      continue
    fi
    # set low frequency on all CPUs
    echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq > /dev/null
    echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq > /dev/null
    # set high frequency on the influential CPU
    echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu${CPU2}/cpufreq/scaling_min_freq > /dev/null
    echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu${CPU2}/cpufreq/scaling_max_freq > /dev/null
    # test frequency via perf
    FREQ=`taskset -c ${CPU1} perf stat --log-fd 1 -e cycles -x ' ' timeout 1s $WHILE_TRUE | grep -v "not counted" - | awk '{print $1}' `
    # it should be 800 MHz, test with 20% addition.
    if [ $FREQ -gt "$(echo "scale=0; 800000000 * 1.2 / 1" | bc -l)" ]; then
      echo "cpu $CPU2 influences cpu $CPU1: frequency of cpu $CPU1 is $FREQ Hz instead of 800MHz"
    fi
  done
done