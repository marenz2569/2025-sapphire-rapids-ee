#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )
cd "$parent_path" || exit

source ./functions.sh

reset_cpu_controls "$@"