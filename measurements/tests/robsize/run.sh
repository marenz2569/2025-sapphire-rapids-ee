#!/usr/bin/env bash

ulimit -n 999999

$ROBSIZE --stop=600 --outfile=$RESULTS_FOLDER/robsize.csv