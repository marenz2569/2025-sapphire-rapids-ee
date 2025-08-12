#!/usr/bin/env bash

mkdir -p $RESULTS_FOLDER/{lic0,lic1,lic2,lic3} || true

echo off | sudo tee /sys/devices/system/cpu/smt/control

# Configure ISST to use
sudo $ISST -c 0-55 core-power assoc --clos 1
sudo $ISST -c 0 core-power assoc --clos 0
sudo $ISST core-power config -c 1 -m 1600
sudo $ISST core-power enable

# Set the FIRESTARTER measurement core to 0
export FIRESTARTER_PERF_CPU=0

# Run each firestarter measurement for 60 seconds and cut away the first 30 and last 5 seconds of the measurement data
START_DELTA=30000
STOP_DELTA=5000
TIMEOUT=60

# Measurement loop. Run all experiments with all number of cores on socket 0.
for ((i = 0 ; i < 56 ; i++)); do
    echo "Running with $i cores."
    if [[ $i -eq 0 ]];
    then
        BINDLIST=0
    else
        BINDLIST=0-$i
    fi

    # sudo, as we need to access /sys/class/powercap
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/lic0/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/lic1/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/lic2/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=L3_L:100         | tail -n 9 > $RESULTS_FOLDER/lic3/$i.csv
done