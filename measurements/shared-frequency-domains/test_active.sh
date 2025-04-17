#!/bin/bash

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

# TODO: remove this once the branch is merged
source ~/lab_management_scripts/.venv/bin/activate
elab ht disable

# for all 56 CPUs
CPUS=`seq 0 55`

for CPU1 in $CPUS; do
  for CPU2 in $CPUS; do
    if [[ $CPU1 -eq $CPU2 ]];
    then
      continue
    fi
    # set low frequency on all CPUs
    elab frequency 800
    # set high frequency on the influential CPU
    elab frequency --cpus ${CPU2} 3800
    # run some workload on influential CPU
    taskset -c ${CPU2} timeout 2s ./while_true &
    # test frequency via perf
    FREQ=`taskset -c ${CPU1} perf stat --log-fd 1 -e cycles -x ' ' timeout 1s ./while_true | grep -v "not counted" - | awk '{print $1}' `
    # it should be 800 MHz, test with 20% addition.
    if [ $FREQ -gt (800000000 * 1.2) ]; then
      echo "cpu $CPU2 influences cpu $CPU1: frequency of cpu $CPU1 is $FREQ Hz instead of 800MHz"
    fi
    sleep 1
  done
done
