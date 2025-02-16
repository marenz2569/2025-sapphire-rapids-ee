#!/usr/bin/env bash

echo "it is $(date)"

lsmod | grep -w msr && echo "MSR already loaded" || { echo "Loading MSR module"; sudo modprobe msr ; }

OUTFILE="../results/$(date +"%Y-%m-%d").datafile"

sudo ./dump-msr.sh | tee $OUTFILE

echo "written results to $OUTFILE"