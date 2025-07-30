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


# parameters: $1: state; $2: $scalingDriver
# $1 = 0: disable, $1 = 1: enable
setBoost () {
    if [ $1 = 0 ]
    then
        echo -e "disabling turbo boost."
    elif [ $1 = 1 ]
    then
        echo -e "enabling turbo boost."
    else
        >&2 echo -e "bad parameter: $1. Use 0 to disable, 1 to enable turbo boost. Aborting."
        exit 1
    fi

    if [ $2 = "acpi-cpufreq" ]
    then
        echo "$1" > /sys/devices/system/cpu/cpufreq/boost
    elif [ $2 = "intel_cpufreq" ]
    then
        echo "$(( \!$1 ))" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
    else
        >&2 echo -e "Error: wrong scaling driver loaded, cannot adjust frequencies. Please reboot with acpi-cpufreq or intel-pstate in passive mode. Aborting"
        exit 1
    fi
}

# check activated scalind driver.
checkDriver () {
    scalingDriver=$( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver )
    echo -e "scaling Driver:\t\t\t${scalingDriver}"
    manualFrequency=false
    if [ $scalingDriver = "acpi-cpufreq" ] || [ $scalingDriver = "intel_cpufreq" ]
    then
        manualFrequency=true
    else
        manualFrequency=false
    fi
}

# check state of scaling governor
# parameters: $1: governor
checkGovernor () {
    governor=$( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor )
    echo -e "Scaling Governor:\t\t${governor}"
}

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
        for states in {0..4}
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
        for cpu in /sys/devices/system/cpu/cpu[0-9]*
        do
            for states in {0..4}
            do
                for stateFile in ${cpu}/cpuidle/state${states}/disable
                do
                    echo "$cstate" | sudo tee $stateFile > /dev/null
                done
            done
        done
    fi
}

# set core frequencies
# parameters: $1: frequency in kHz; $2: first core to apply frequency to; $3: last core to apply frequency to
setFrequency () {
    if [ $4 = "acpi-cpufreq" ]
    then
        for ((f=$2;f<=$3;f++))
        do
            echo "$1" > /sys/devices/system/cpu/cpu$f/cpufreq/scaling_setspeed
            if [ $( cat /sys/devices/system/cpu/cpu$f/cpufreq/scaling_setspeed ) != $1 ]
            then
                >&2 echo "Error: unable to set frequency for core $f, check setup; aborting."
                exit 1
            fi
        done
    elif [ $4 = "intel_cpufreq" ]
    then
        for ((f=$2;f<=15;f++))
        do
            echo "$1" > /sys/devices/system/cpu/cpu$f/cpufreq/scaling_min_freq
            echo "$1" > /sys/devices/system/cpu/cpu$f/cpufreq/scaling_max_freq
            if [ $f -lt 8 ]
            then
                if [ $( cat /sys/devices/system/cpu/cpu$f/cpufreq/scaling_min_freq ) != $1 ] || [ $( cat /sys/devices/system/cpu/cpu$f/cpufreq/scaling_max_freq ) != $1 ]
                then
                    >&2 echo "Error: unable to set frequency for core $f, check setup; aborting."
                    exit 1
                fi
            fi
        done
        for ((f=16;f<=23;f++))
        do
            echo "2400000" > /sys/devices/system/cpu/cpu$f/cpufreq/scaling_min_freq
            echo "2400000" > /sys/devices/system/cpu/cpu$f/cpufreq/scaling_max_freq
            if [ $( cat /sys/devices/system/cpu/cpu$f/cpufreq/scaling_min_freq ) != 2400000 ] || [ $( cat /sys/devices/system/cpu/cpu$f/cpufreq/scaling_max_freq ) != 2400000 ]
            then
                >&2 echo "Error: unable to set frequency for core $f, check setup; aborting."
                exit 1
            fi
        done
    fi
}

# 1) workload on p-core
# 1.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
# 1.2) turbo disabled, userspace governor, 3.2 GHz core frequency, automatic uncore frequency selection in full range
# 1.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
# 1.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
# 1.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz
# 1.6) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 0.8 GHz
# 1.7) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 3.2 GHz
# 1.8) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 4.7 GHz
#
# 2) workload on e-core
# 2.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
# 2.2) turbo disabled, userspace governor, 2.3 GHz core frequency, automatic uncore frequency selection in full range
# 2.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
# 2.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
# 2.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz
# 2.6) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 0.8 GHz
# 2.7) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 2.3 GHz
# 2.8) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 4.7 GHz
#
# 3) workload on p-core and e-core
# 3.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
# 3.2) turbo disabled, userspace governor, P-Core @2.3 GHz, E-Core @800 MHz, automatic uncore frequency selection
# 3.3) turbo disabled, userspace governor, P-Core @800 MHz, E-Core @2.3 GHz, automatic uncore frequency selection
#
# 4) STREAM on p-cores
# 4.1) STREAM on P-Cores, all cores at turbo, c-states disabled
# 4.2) STREAM on P-Cores, all cores at turbo, E-Cores in C1E
# 4.3) STREAM on P-Cores, all cores at turbo, c-states enabled for all cores

checkDriver

echo -e "Can set frequencies:\t\t${manualFrequency}"

# abort if frequency cannot be set manually, as this is required for all tests
if [ $manualFrequency = false ]
then
    >&2 echo -e "Error: Cannot set frequencies, please enable the acpi-cpufreq or intel_cpufreq driver"
    exit 1
fi

# set userspace-governor if necessary, needed for all tests
if [[ $governor != "ondemand" ]]
then
    setGovernor "ondemand"
    checkGovernor
fi

toggleCstates 0

checkCstates

sudo modprobe msr

gcc -fopenmp while_true.c -o while_true.out

section_begin="\n######## "
section_end=" ########"

# 1) workload on p-core
echo -e "${section_begin}1) workload on p-core${section_end}"

# 1.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
echo -e "${section_begin}1.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 8
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x82f

setBoost 1 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.2) turbo disabled, userspace governor, 3.2 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.2) turbo disabled, userspace governor, 3.2 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

# set userspace-governor if necessary, needed for all tests
if [ $governor != "userspace" ]
then
    setGovernor "userspace"
    checkGovernor
fi

echo $scalingDriver

setFrequency 3200000 0 23 $scalingDriver

setBoost 0 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}1.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 0 23 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 8
sudo wrmsr 0x620 0x808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz
echo -e "${section_begin}1.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 47
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x2f2f

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.6) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}1.6) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 3200000 0 23 $scalingDriver

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 8
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 8
sudo wrmsr 0x620 0x808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.7) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 3.2 GHz
echo -e  "${section_begin}1.7) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 3.2 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 32
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 32
sudo wrmsr 0x620 0x2020

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out

# 1.8) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 4.7 GHz
echo -e "${section_begin}1.8) turbo disabled, userspace governor, 3.2 GHz core frequency, uncore frequency at 4.7 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 47
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x2f2f

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0 timeout 10s ./while_true.out


# 2) workload on e-core
echo -e "${section_begin}2) workload on e-core${section_end}"

# 2.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
echo -e "${section_begin}2.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range${section_end}"

if [ $governor != "ondemand" ]
then
    setGovernor "ondemand"
    checkGovernor
fi

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 8
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x82f

setBoost 1 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.2) turbo disabled, userspace governor, 2.3 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}2.2) turbo disabled, userspace governor, 2.3 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

if [ $governor != "userspace" ]
then
    setGovernor "userspace"
    checkGovernor
fi

setFrequency 2300000 0 23 $scalingDriver

setBoost 0 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range
echo -e "${section_begin}2.3) turbo disabled, userspace governor, 0.8 GHz core frequency, automatic uncore frequency selection in full range${section_end}"

setFrequency 800000 0 23 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}2.4) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 8
sudo wrmsr 0x620 0x808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz
echo -e "${section_begin}2.5) turbo disabled, userspace governor, 0.8 GHz core frequency, uncore frequency at 4.7 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 47
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x2f2f

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.6) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 0.8 GHz
echo -e "${section_begin}2.6) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 0.8 GHz${section_end}"

setFrequency 2300000 0 23 $scalingDriver

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 8
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 8
sudo wrmsr 0x620 0x808

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.7) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 2.3 GHz
echo -e  "${section_begin}2.7) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 2.3 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 23
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 23
sudo wrmsr 0x620 0x1717

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 2.8) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 4.7 GHz
echo -e "${section_begin}2.8) turbo disabled, userspace governor, 2.3 GHz core frequency, uncore frequency at 4.7 GHz${section_end}"

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 47
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x2f2f

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 23 timeout 10s ./while_true.out

# 3) workload on p-core and e-core
echo -e "${section_begin}3) workload on p-core and e-core${section_end}"

# 3.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range
echo -e "${section_begin}3.1) turbo enabled, ondemand governor, automatic uncore frequency selection in full range${section_end}"

if [ $governor != "ondemand" ]
then
    setGovernor "ondemand"
    checkGovernor
fi

#x86a_write -n -i Intel_UNCORE_MIN_RATIO -V 8
#x86a_write -n -i Intel_UNCORE_MAX_RATIO -V 47
sudo wrmsr 0x620 0x82f

setBoost 1 $scalingDriver

OMP_NUM_THREADS=2 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0,23 taskset -c 0,23 timeout 10s ./while_true.out

elab frequency auto

# 3.2) turbo disabled, userspace governor, P-Core @2.3 GHz, E-Core @800 MHz, automatic uncore frequency selection
echo -e "${section_begin}3.2) turbo disabled, userspace governor, P-Core @2.3 GHz, E-Core @800 MHz, automatic uncore frequency selection${section_end}"

if [ $governor != "userspace" ]
then
    setGovernor "userspace"
    checkGovernor
fi
setFrequency 2300000 0 15 $scalingDriver
setFrequency 800000 16 23 $scalingDriver

setBoost 0 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0 taskset -c 0 timeout 10s ./while_true.out &
OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 23 taskset -c 23 timeout 10s ./while_true.out

# 3.3) turbo disabled, userspace governor, P-Core @800 MHz, E-Core @2.3 GHz, automatic uncore frequency selection
echo -e "${section_begin}3.3) turbo disabled, userspace governor, P-Core @800 MHz, E-Core @2.3 GHz, automatic uncore frequency selection${section_end}"

setFrequency 800000 0 15 $scalingDriver
setFrequency 2300000 16 23 $scalingDriver

setBoost 0 $scalingDriver

OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 0 taskset -c 0 timeout 10s ./while_true.out &
OMP_NUM_THREADS=1 perf stat -I 1000 -e cycles,task-clock,uncore_clock/clockticks/ -a -A -C 23 taskset -c 23 timeout 10s ./while_true.out

echo -e "${section_begin}Enabling ondemand governor, enabling turbo boost, setting detaulf uncore frequency range${section_end}"

#enable ondemand governor
if [ $governor != "ondemand" ]
then
    setGovernor "ondemand"
    checkGovernor
fi

#enable turbo boost
setBoost 1 $scalingDriver

# reset uncore frequency to default values
sudo wrmsr 0x620 0x82f
