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


# set scaling governor
# parameters: $1: governor
setGovernor () {
    echo -e "attempting to set scaling governor to ${1}"
    for f in /sys/devices/system/cpu/cpu[0-9]*
    do
        echo "${1}" > $f/cpufreq/scaling_governor
    done

    g=$( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor )
    if [ $g != "$1" ]
    then
        >&2 echo -e "Error: governor $1 has not been set, instead, $governor is used. Aborting."
        exit 1
    fi
}

# check status of c-states
checkCstates () {
    cstatesState="enabled"
    stateCheck=0
    for cpu in /sys/devices/system/cpu/cpu[0-9]*
    do
        for states in {0..3}
        do
            for stateFile in ${cpu}/cpuidle/state${states}/disable
            do

                state=$( cat $stateFile )
                if [ $state == 0 ]
                then
                    stateCheck=$(( $stateCheck+1 ))
                fi
            done
        done
    done

    if [ $stateCheck != 0 ]
    then
        cstatesState="enabled"
    else
        cstatesState="disabled"
    fi

    echo -e "Cstates:\t\t\t${cstatesState}"
}

# change c-state state (enable, disable)
toggleCstates () {
    cstate=$1

    if [ $cstate != 0 ] && [ $cstate != 1 ]
    then
        echo "toggleCstates: wrong input parameter, must be 0 (enable) or 1 (disable)"
    else
        echo -n "$cstate" | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable > /dev/null
    fi
}

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

setGovernor "performance"

toggleCstates 0

checkCstates

sudo modprobe msr

gcc -fopenmp while_true.c -o while_true.out

section_begin="\n######## "
section_end=" ########"

# 1) workload on p-core
echo -e "${section_begin}1) workload on p-core${section_end}"

# 1.1) turbo enabled,  performance governor, automatic uncore frequency selection in full range
echo -e "${section_begin}1.1) turbo enabled,  performance governor, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 3800000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.1.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.1.uncore.log 2> /dev/null
wait

# 1.2) turbo disabled, performance governor, 2.0 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.2) turbo disabled, performance governor, 2.0 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.2.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.2.uncore.log 2> /dev/null
wait

# 1.3) turbo disabled, performance governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.3) turbo disabled, performance governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x0819

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.3.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.3.uncore.log 2> /dev/null
wait

# 1.4) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.4) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x0808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.4.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.4.uncore.log 2> /dev/null
wait

# 1.5) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 2.5 GHz
echo -e "${section_begin}1.5) turbo disabled, performance governor, 0.8 GHz core frequency, uncore frequency at 2.5 GHz${section_end}"

setFrequency 800000 800000
sudo wrmsr 0x620 0x1919

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.5.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.5.uncore.log 2> /dev/null
wait

# 1.6) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.6) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x0808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.6.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.6.uncore.log 2> /dev/null
wait

# 1.7) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.0 GHz
echo -e  "${section_begin}1.7) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.0 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x1414

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.7.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.7.uncore.log 2> /dev/null
wait

# 1.8) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.5 GHz
echo -e "${section_begin}1.8) turbo disabled, performance governor, 2.0 GHz core frequency, uncore frequency at 2.5 GHz${section_end}"

setFrequency 2000000 2000000
sudo wrmsr 0x620 0x1919

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock -a -A -C 0 -o 1.8.perf.log taskset -c 0 timeout 10s ./while_true.out &
sudo /home/s2599166/intel-uncore-freq-dumper/build/src/intel-uncore-freq-dumper --outfile 1.8.uncore.log 2> /dev/null
wait

# switch back to green governor
setGovernor "powersave"
setFrequency 800000 3800000
sudo wrmsr 0x620 0x0819
