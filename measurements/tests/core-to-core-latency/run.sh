#!/usr/bin/env bash

# set nominal core frequency
echo "2000000" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
echo "2000000" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

# Set lowest uncore frequency
sudo wrmsr -a 0x620 0x0808

cd $RESULTS_FOLDER

# do a ping pong between the cores 0 and 1, repeat each pingpong for 100 times,
# use 1000 caches lines, each with a size of 64B and repeat the measurement for 1000 times.
# this will save flush_results.txt and latency_results.txt
taskset -c 0,1 $ATOMIC_LATENCIES 0,1 100 1000 64 1000