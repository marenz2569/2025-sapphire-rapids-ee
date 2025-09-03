#!/usr/bin/env bash

echo off | sudo tee /sys/devices/system/cpu/smt/control

export GOMP_CPU_AFFINITY=0-111
export METRICQ_METRICS=elab.hati.pdu.power

echo "environment variables:"
echo "  GOMP_CPU_AFFINITY = $GOMP_CPU_AFFINITY"
echo "  METRICQ_METRICS   = $METRICQ_METRICS"
echo "executing test..."

sudo -E env LD_LIBRARY_PATH=${LD_LIBRARY_PATH} $ROCO2 --csv-output $RESULTS_FOLDER/results.csv
