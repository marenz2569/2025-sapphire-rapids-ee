#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

source functions.sh

# Create the folder for the results of measurement
export RESULTS_FOLDER=${TEST_ROOT}/$(uname -n)/${TEST_NAME}/$(date +"%Y-%m-%d-%H%M")
mkdir -p $RESULTS_FOLDER

# Write the current git-rev into the results folder
git describe --always --abbrev=40 --dirty > $RESULTS_FOLDER/git-tag

# Write the current /proc/cmdline into the results folder
cat /proc/cmdline > $RESULTS_FOLDER/proc-cmdline

reset_cpu_controls "performance"

# Execute the command of the measurement passed via the arguments
$@

# Switch back to a green governor
reset_cpu_controls "powersave"