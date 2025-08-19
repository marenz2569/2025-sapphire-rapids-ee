#!/usr/bin/env bash

# This test needs to run on CPU 0, as the code for the UFS latency measurement reads and writes the MSR on this specific CPU.

# sudo taskset -c 0 stdbuf -oL $UFS_MANUAL > $RESULTS_FOLDER/manual.performance.out
# sudo taskset -c 0 stdbuf -oL $UFS_AUTOMATIC > $RESULTS_FOLDER/automatic.performance.out

# Run at nominal frequency
echo 2000000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 2000000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

# shellcheck disable=SC2024
sudo taskset -c 0 stdbuf -oL $UFS_MANUAL > $RESULTS_FOLDER/manual.2000.out

# Run at lowest frequency
echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq

# shellcheck disable=SC2024
sudo taskset -c 0 stdbuf -oL $UFS_MANUAL > $RESULTS_FOLDER/manual.800.out