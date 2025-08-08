#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

lsmod | grep -w msr && echo "MSR already loaded" || { echo "Loading MSR module"; sudo modprobe msr ; }

sudo ./dump-msr.sh | tee $RESULTS_FOLDER/stdout.log