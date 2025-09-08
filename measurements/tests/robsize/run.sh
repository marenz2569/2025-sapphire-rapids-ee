#!/usr/bin/env bash

# Take hyperthreads offline
echo off | sudo tee /sys/devices/system/cpu/smt/control

ulimit -n 999999

$ROBSIZE --stop=600 --outfile=$RESULTS_FOLDER/robsize.csv