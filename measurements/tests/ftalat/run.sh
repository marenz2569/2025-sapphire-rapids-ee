#!/usr/bin/env bash

# Test if the processor supports scaling_available_frequencies
# If it does, we will use the userspace governour and write to scaling_setspeed
# if not, we use the performance governor and write to scaling_max_speed
test -e /sys/bus/cpu/devices/cpu0/cpufreq/scaling_available_frequencies
# shellcheck disable=SC2319
scaling_available_frequencies_found=$?

if [ $scaling_available_frequencies_found -eq 0 ]
then
	IFS=" " read -r -a frequencies <<< "$(cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_available_frequencies)"

	echo userspace | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_governor
	# Set all threads to the lowest frequency
	cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_min_freq | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_setspeed
else
	# loop over to scaling_min_frequency to scaling_max_frequency in 100kHz steps
	frequencies=()
	min_frequency=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_min_freq`
	max_frequency=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_max_freq`
    for ((i = min_frequency ; i <= max_frequency ; i+=100000)); do
		frequencies+=( "$i" )
	done

	echo performance | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_governor
	# Set all threads to the lowest frequency
	cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_min_freq | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq
fi

echo "Running ftalat for following frequencies:"
printf '%s ' "${frequencies[@]}"
echo ""

# Disable cstates
echo 1 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable

# Take hyperthreads offline
echo off | sudo tee /sys/devices/system/cpu/smt/control

if [ $scaling_available_frequencies_found -eq 0 ]
then
	FTALAT=$FTALAT_SCALING_SETSPEED
else
	FTALAT=$FTALAT_SCALING_MAX_FREQ
fi

for START in "${frequencies[@]}"
do
	for TARGET in "${frequencies[@]}"
	do
		if [ $START -eq $TARGET ]
		then
			echo "Skipping $START -> $TARGET (same frequency)"
			continue
		fi
		echo "Running $START -> $TARGET"
		# shellcheck disable=SC2024
		sudo $FTALAT $START $TARGET > $RESULTS_FOLDER/${START}_${TARGET}.txt
	done
done