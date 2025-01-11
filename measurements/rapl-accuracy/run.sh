#!/usr/bin/env bash

module purge --force
module load toolchain/system scorep_metricq lo2s

echo "it is $(date)"

git clone -b marenz.hati-config git@github.com:marenz2569/roco2.git || true

cd roco2

git pull

mkdir build || true

cd build

SCOREP_WRAPPER_INSTRUMENTER_FLAGS='--user --openmp --thread=omp --nocompiler' SCOREP_WRAPPER=off cmake .. -DCMAKE_C_COMPILER=scorep-gcc -DCMAKE_CXX_COMPILER=scorep-g++ -DUSE_SCOREP=ON -DUSE_FIRESTARTER=OFF
SCOREP_WRAPPER_INSTRUMENTER_FLAGS='--user --openmp --thread=omp --nocompiler' make -j

cd ../../

export GOMP_CPU_AFFINITY=0-223

export SCOREP_ENABLE_TRACING=1
export SCOREP_ENABLE_PROFILING=0
export SCOREP_TOTAL_MEMORY=4095M
export SCOREP_METRIC_METRICQ_PLUGIN_TIMEOUT=12h

export LO2S_OUTPUT_LINK=$(pwd)/lo2s_trace_latest

echo "environment variables:"
echo "  GOMP_CPU_AFFINITY                    = $GOMP_CPU_AFFINITY"
echo "  SCOREP_ENABLE_TRACING                = $SCOREP_ENABLE_TRACING"
echo "  SCOREP_ENABLE_PROFILING              = $SCOREP_ENABLE_PROFILING"
echo "  SCOREP_TOTAL_MEMORY                  = $SCOREP_TOTAL_MEMORY"
echo "  SCOREP_METRIC_PLUGINS                = $SCOREP_METRIC_PLUGINS"
echo "  SCOREP_METRIC_METRICQ_PLUGIN_TIMEOUT = $SCOREP_METRIC_METRICQ_PLUGIN_TIMEOUT"
echo "  LO2S_OUTPUT_LINK                     = $LO2S_OUTPUT_LINK"

echo "executing test..."

ulimit -n 999999

perf probe -d roco2:metrics

sudo perf probe -x ./roco2/build/src/experiment/hati roco2:metrics=_ZN5roco27metrics4meta5writeEmmlmmmm experiment frequency shell threads utility || exit 1

lo2s \
-X -t roco2:metrics \
-- ./roco2/build/src/experiment/hati

echo "done"