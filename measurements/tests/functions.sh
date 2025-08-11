#!/usr/bin/env bash

# Reset the the SMT control, cpu frequency and intel-speed-select back to defaults.
# The first argument specifes which cpu governor should be applied
function reset_cpu_controls() {
    # Switch all cpus on
    echo on | sudo tee /sys/devices/system/cpu/smt/control

    # Enable cstates
    echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/*/disable

    # Use specified governor
    echo $1 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

    # Restore full cpu frequency range
    echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
    echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

    # Test if kernel supports the ISST interface
    $(test -e /dev/isst)
    isst_found=$?

    if [ $isst_found -eq 0 ]
    then
        # Disable ISST
        sudo $ISST base-freq disable
        sudo $ISST turbo-freq disable
        sudo $ISST core-power disable
    fi

    # Enable RAPL readout
    sudo modprobe intel_rapl_msr
}