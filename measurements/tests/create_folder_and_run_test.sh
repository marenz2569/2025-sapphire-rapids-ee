#!/usr/bin/env bash

# Create the folder for the results of measurement
export RESULTS_FOLDER=${TEST_ROOT}/$(uname -n)/${TEST_NAME}/$(date +"%Y-%m-%d-%H%M")
mkdir -p $RESULTS_FOLDER

# switch all cpus on
echo on | sudo tee /sys/devices/system/cpu/smt/control

# enable cstates
echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/*/disable

# use performance governor
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

# Disable ISST
sudo $ISST base-freq disable
sudo $ISST turbo-freq disable
sudo $ISST core-power disable

# Execute the command of the measurement passed via the arguments
exec $@

# switch all cpus on
echo on | sudo tee /sys/devices/system/cpu/smt/control

# enable cstates
echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/*/disable

# use powersave governor
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

# Disable ISST
sudo $ISST base-freq disable
sudo $ISST turbo-freq disable
sudo $ISST core-power disable