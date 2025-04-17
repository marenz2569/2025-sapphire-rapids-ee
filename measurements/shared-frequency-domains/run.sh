#!/bin/bash

mkdir -p results
ACTIVE_OUTFILE="results/active_$(date +"%Y-%m-%d").datafile"
IDLE_OUTFILE="results/idle_$(date +"%Y-%m-%d").datafile"

./test_active.sh > $ACTIVE_OUTFILE
./test_idle.sh > $IDLE_OUTFILE
