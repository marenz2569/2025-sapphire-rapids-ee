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

echo "void main(){while(1);}" > while_true.c
gcc while_true.c -o while_true

CALLER=0 # The CPU that wakes up other CPUs (a P core)
CALLEE_LOCAL=1 # the CPU that is called locally ( a P core)
BUSY_LOCAL=2 # a CPU that bears some load during the measurement of CALLEE_LOCAL
CALLEE_REMOTE=16 # a "remote" CPU, a.k.a. an E-core
BUSY_REMOTE=17 # another E-core on the same module that is active for measurement of "waking an E-core, but not the whole module"
NTIMES=100 # the number of measurements
FREQS=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies` # the supported frequencies
WAIT_US=100000 # how long to wait between measurements (so that the callee can fall back to idle)

CSTATES=`ls /sys/devices/system/cpu/cpu0/cpuidle/` # here, the C-states are stored

echo userspace | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

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
		echo $FREQ | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed
		sleep 0.1
		taskset -c $CALLER perf record -e sched:sched_waking -C $CALLER -o perf.data.local_caller.$CSTATE.$FREQ.$CALLER.$CALLEE_LOCAL &
                taskset -c $CALLEE_LOCAL perf record -e power:cpu_idle -C $CALLEE_LOCAL -o perf.data.local_callee.$CSTATE.$FREQ.$CALLER.$CALLEE_LOCAL &
		./cond_wait $CALLER $CALLEE_LOCAL $NTIMES $WAIT_US
		killall perf
	done

        # remote idle
        for FREQ in $FREQS
        do
                echo $FREQ | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed
                sleep 0.1
                taskset -c $CALLER perf record -e sched:sched_waking -C $CALLER -o perf.data.remote_idle_caller.$CSTATE.$FREQ.$CALLER.$CALLEE_REMOTE &
                taskset -c $CALLEE_REMOTE perf record -e power:cpu_idle -C $CALLEE_REMOTE -o perf.data.remote_idle_callee.$CSTATE.$FREQ.$CALLER.$CALLEE_REMOTE &
                ./cond_wait $CALLER $CALLEE_REMOTE $NTIMES $WAIT_US
                killall perf
        done

        killall while_true

	# remote active
	taskset -c $BUSY_LOCAL ./while_true &
	taskset -c $BUSY_REMOTE ./while_true &
	for FREQ in $FREQS
	do
		echo $FREQ | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed
		sleep 0.1
                taskset -c $CALLER perf record -e sched:sched_waking -C $CALLER -o perf.data.remote_active_caller.$CSTATE.$FREQ.$CALLER.$CALLEE_REMOTE &
                taskset -c $CALLEE_REMOTE perf record -e power:cpu_idle -C $CALLEE_REMOTE -o perf.data.remote_active_callee.$CSTATE.$FREQ.$CALLER.$CALLEE_REMOTE &
                ./cond_wait $CALLER $CALLEE_REMOTE $NTIMES $WAIT_US
                killall perf
	done
	killall while_true
done


