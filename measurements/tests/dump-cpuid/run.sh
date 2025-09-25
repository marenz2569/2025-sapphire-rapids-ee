#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )
cd "$parent_path" || exit

taskset -c 0 nix run .#cpuid -- -1 > $RESULTS_FOLDER/cpuid.out