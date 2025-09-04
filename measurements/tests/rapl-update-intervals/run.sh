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
else
	# loop over to scaling_min_frequency to scaling_max_frequency in 100kHz steps
	frequencies=()
	min_frequency=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_min_freq`
	max_frequency=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_max_freq`
    for ((i = min_frequency ; i <= max_frequency ; i+=100000)); do
		frequencies+=( "$i" )
	done

	echo performance | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_governor
fi

echo "Running rapl-update-intervals for following frequencies:"
printf '%s ' "${frequencies[@]}"
echo ""

# $1: The frequency which should be set
function set_frequency() {
    if [ $scaling_available_frequencies_found -eq 0 ]
    then
        echo $1 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed
    else
    	echo $1 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
    	echo $1 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq
    fi
}

function enable_rapl_filter() {
    # Register Address: BCH, 188 IA32_MISC_PACKAGE_CTLS
    # Power Filtering Control (R/W)
    # This MSR has a value of 0 after reset and is unaffected by INIT# or SIPI#.
    # If IA32_ARCH_CAPABILITIES
    # [10] = 1
    #
    # 0 ENERGY_FILTERING_ENABLE (R/W)
    # If set, RAPL MSRs report filtered processor power consumption data.
    # This bit can be changed from 0 to 1, but cannot be changed from 1 to 0.
    # After setting, all attempts to clear it are ignored until the next processor
    # reset.
    # If IA32_ARCH_CAPABILITIES
    # [11] = 1
    #
    # 63:1 Reserved.
    sudo wrmsr 0xbc -a 1
}

# Assert that the RAPL filter is disabled
rapl_filter_enabled=$(sudo rdmsr 0xbc -p 0)

if [ $rapl_filter_enabled -ne 0 ]
then
    echo "RAPL filter is enabled. Need to reboot the system!"
    # Reboot the system in 1 minute
    sudo shutdown -r +1
    exit 1
fi

# Run FIRESTARTER to generate some energy usage
$FIRESTARTER -b 1 &

for frequency in "${frequencies[@]}"
do
    set_frequency $frequency
    # shellcheck disable=SC2024
    sudo timeout 5 taskset -c 0 $RAPL_UPDATE_INTERVALS > $RESULTS_FOLDER/results_${frequency}_NOFILTER.csv
done

# Disable cstates
echo 1 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable

for frequency in "${frequencies[@]}"
do
    set_frequency $frequency
    # shellcheck disable=SC2024
    sudo timeout 5 taskset -c 0 $RAPL_UPDATE_INTERVALS > $RESULTS_FOLDER/results_${frequency}_NOFILTER_POLL.csv
done

# Enable the RAPL filter
enable_rapl_filter

# Enable cstates
echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable

for frequency in "${frequencies[@]}"
do
    set_frequency $frequency
    # shellcheck disable=SC2024
    sudo timeout 5 taskset -c 0 $RAPL_UPDATE_INTERVALS > $RESULTS_FOLDER/results_${frequency}_FILTER.csv
done

# Disable cstates
echo 1 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/state*/disable

for frequency in "${frequencies[@]}"
do
    set_frequency $frequency
    # shellcheck disable=SC2024
    sudo timeout 5 taskset -c 0 $RAPL_UPDATE_INTERVALS > $RESULTS_FOLDER/results_${frequency}_FILTER_POLL.csv
done

killall FIRESTARTER

echo "All measurements complete"
echo "RAPL filter is enabled. Need to reboot the system!"
# Reboot the system in 1 minute
sudo shutdown -r +1