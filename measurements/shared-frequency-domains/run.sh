#!/bin/bash

mkdir -p results
OUTFILE="results/active_$(date +"%Y-%m-%d").datafile"

./test_active.sh > $OUTFILE
