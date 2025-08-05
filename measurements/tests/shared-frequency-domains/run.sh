#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

./test_active.sh > $RESULTS_FOLDER/active.log
./test_idle.sh > $RESULTS_FOLDER/idle.log