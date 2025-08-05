#!/usr/bin/env bash

# Create the folder for the results of measurement
export RESULTS_FOLDER=${TEST_ROOT}/$(uname -n)/${TEST_NAME}/$(date +"%Y-%m-%d-%H%M")
mkdir -p $RESULTS_FOLDER

# Execute the command of the measurement passed via the arguments
exec $@