#!/usr/bin/env bash

# TODO: add build for this module
module load firestarter-metric-metricq

echo "it is $(date)"

git clone -b marenz.hati-config git@github.com:marenz2569/roco2.git || true

cd roco2

git pull

mkdir build || true

cd build

cmake ..
make -j

cd ../../

export GOMP_CPU_AFFINITY=0-223
export METRICQ_METRICS=elab.hati.pdu.power

echo "environment variables:"
echo "  GOMP_CPU_AFFINITY = $GOMP_CPU_AFFINITY"
echo "  METRICQ_METRICS   = $METRICQ_METRICS"
echo "executing test..."

./roco2/build/src/configurations/hati/roco2_hati

echo "done"

OUTFILE="results/$(date +"%Y-%m-%d").csv"

mv results.csv $OUTFILE

echo "written results to $OUTFILE"