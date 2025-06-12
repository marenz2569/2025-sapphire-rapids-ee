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

gcc -pthread cond_wait.c -o cond_wait
gcc while_true.c -o while_true

CALLER=0 # The CPU that wakes up other CPUs
CALLEE_LOCAL=1 # the CPU that is called locally
BUSY_LOCAL=2 # a CPU that bears some load during the measurement of CALLEE_LOCAL
NTIMES=100 # the number of measurements
FREQS=(800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000) # the supported frequencies
WAIT_US=100000 # how long to wait between measurements (so that the callee can fall back to idle)

CSTATES=`ls /sys/devices/system/cpu/cpu0/cpuidle/` # here, the C-states are stored

#disable all
for CSTATE in $CSTATES
do
	echo 1 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/$CSTATE/disable
done


for CSTATE in $CSTATES
do
	# enable lowest C-state
	echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/$CSTATE/disable

	# local
	taskset -c $BUSY_LOCAL ./while_true &
	for FREQ in $FREQS
	do
		echo $FREQ | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq
		sleep 0.1
		taskset -c $CALLER perf record -e sched:sched_waking -C $CALLER -o perf.data.local_caller.$CSTATE.$FREQ.$CALLER.$CALLEE_LOCAL &
        taskset -c $CALLEE_LOCAL perf record -e power:cpu_idle -C $CALLEE_LOCAL -o perf.data.local_callee.$CSTATE.$FREQ.$CALLER.$CALLEE_LOCAL &
		./cond_wait $CALLER $CALLEE_LOCAL $NTIMES $WAIT_US
		killall perf
	done

    killall while_true
done