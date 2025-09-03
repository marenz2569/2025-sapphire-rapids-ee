#!/usr/bin/env bash

echo off | sudo tee /sys/devices/system/cpu/smt/control

export GOMP_CPU_AFFINITY=0-111
export METRICQ_METRICS=elab.hati.pdu.power

echo "environment variables:"
echo "  GOMP_CPU_AFFINITY = $GOMP_CPU_AFFINITY"
echo "  METRICQ_METRICS   = $METRICQ_METRICS"
echo "executing test..."

$ROCO2 --csv-output $RESULTS_FOLDER/results.csv
