#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )
cd "$parent_path" || exit

source functions.sh

# Create the folder for the results of measurement
uname_n=$(uname -n)
date_string=$(date +"%Y-%m-%d-%H%M")
export RESULTS_FOLDER=${TEST_ROOT}/${uname_n}/${TEST_NAME}/${date_string}
mkdir -p $RESULTS_FOLDER

# Reset to a specified system state
reset_cpu_controls "performance"

# Write the current git-rev into the results folder
git describe --always --abbrev=40 --dirty > $RESULTS_FOLDER/git-tag

# Write the current /proc/cmdline into the results folder
cat /proc/cmdline > $RESULTS_FOLDER/proc-cmdline

# Write lsmod into the results folder
lsmod > $RESULTS_FOLDER/lsmod

# dump hwloc topology information
mkdir $RESULTS_FOLDER/hwloc-topology
sudo $HWLOC_GATHER_TOPOLOGY --io --dmi --dt $RESULTS_FOLDER/hwloc-topology/hwloc-gather-topology

# dump lshw xml file
# shellcheck disable=SC2024
sudo lshw -xml > $RESULTS_FOLDER/lshw.xml

# Execute the command of the measurement passed via the arguments
"$@"

# Switch back to a green governor
reset_cpu_controls "powersave"