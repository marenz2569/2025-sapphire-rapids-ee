#!/usr/bin/env bash

mkdir $RESULTS_FOLDER/{lowest_uncore,highest_uncore,nominal_uncore}

# set nominal core frequency
echo "2000000" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
echo "2000000" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

cd $RESULTS_FOLDER/nominal_uncore

# do a ping pong between the cores 0 and 1, repeat each pingpong for 100 times,
# use 1000 caches lines, each with a size of 64B and repeat the measurement for 1000 times.
# this will save flush_results.txt and latency_results.txt
taskset -c 0,1 $ATOMIC_LATENCIES 0,1 100 1000 64 1000

# Set lowest uncore frequency
sudo wrmsr -a 0x620 0x0808

cd $RESULTS_FOLDER/lowest_uncore

# do a ping pong between the cores 0 and 1, repeat each pingpong for 100 times,
# use 1000 caches lines, each with a size of 64B and repeat the measurement for 1000 times.
# this will save flush_results.txt and latency_results.txt
taskset -c 0,1 $ATOMIC_LATENCIES 0,1 100 1000 64 1000

# Set highest uncore frequency
sudo wrmsr -a 0x620 0x1919

cd $RESULTS_FOLDER/highest_uncore

# do a ping pong between the cores 0 and 1, repeat each pingpong for 100 times,
# use 1000 caches lines, each with a size of 64B and repeat the measurement for 1000 times.
# this will save flush_results.txt and latency_results.txt
taskset -c 0,1 $ATOMIC_LATENCIES 0,1 100 1000 64 1000