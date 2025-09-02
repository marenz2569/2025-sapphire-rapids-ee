#!/usr/bin/env bash

# Traverse to the path of this script
# https://stackoverflow.com/a/24112741
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" || exit ; pwd -P )
cd "$parent_path" || exit

# Alias elab to execute the elab tool of experiment_utils with root
# sudo -E is required to have sudo working inside the nix chroot
alias elab='sudo -E $(which nix) run .#elab --'

echo off | sudo tee /sys/devices/system/cpu/smt/control

export GOMP_CPU_AFFINITY=0-111
export METRICQ_METRICS=elab.hati.pdu.power

echo "environment variables:"
echo "  GOMP_CPU_AFFINITY = $GOMP_CPU_AFFINITY"
echo "  METRICQ_METRICS   = $METRICQ_METRICS"
echo "executing test..."

$ROCO2 --csv-output $RESULTS_FOLDER/results.csv