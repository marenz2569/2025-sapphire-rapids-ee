#!/usr/bin/env bash

# Reset the the SMT control, cpu frequency and intel-speed-select back to defaults.
# The first argument specifes which cpu governor should be applied
function reset_cpu_controls() {
    local hostname=$(hostname)

    # Switch all cpus on
    echo on | sudo tee /sys/devices/system/cpu/smt/control

    # Enable cstates
    echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/*/disable

    # Use specified governor
    echo $1 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

    # Enable RAPL readout
    lsmod | grep -w intel_rapl_msr && echo "intel_rapl_msr already loaded" || { echo "Loading intel_rapl_msr module"; sudo modprobe intel_rapl_msr ; }

    # Enable MSR readout
    lsmod | grep -w msr && echo "MSR already loaded" || { echo "Loading MSR module"; sudo modprobe msr ; }

    if [[ $hostname -eq "hati" ]]; then
        # Restore full cpu frequency range
        echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
        echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

        # Restore uncore frequency range
        sudo wrmsr -a 0x620 0x0819
    else if [[ $hostname -eq "ariel" ]]; then
        # Restore full cpu frequency range
        echo 1200000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
        echo 3001000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

        # Restore uncore frequency range
        sudo wrmsr -a 0x620 0x0c18
    else
        echo "Host $hostname is not supported by the reset_cpu_controls function"
        exit 1
    fi

    # Test if kernel supports the ISST interface
    $(test -e /dev/isst_interface)
    isst_found=$?

    if [ $isst_found -eq 0 ]
    then
        # Disable ISST
        sudo $ISST base-freq disable
        sudo $ISST turbo-freq disable
        sudo $ISST core-power disable
    fi
}