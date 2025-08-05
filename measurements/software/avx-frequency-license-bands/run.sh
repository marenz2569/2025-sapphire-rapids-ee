#!/usr/bin/env bash

sudo $ISST perf-profile info 2>&1 | tee $RESULTS_FOLDER/isst-perf-profile.log