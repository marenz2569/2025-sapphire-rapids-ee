#!/usr/bin/env bash

mkdir -p $RESULTS_FOLDER/{normal,alt}/{lic0,lic1,lic2,lic3} || true

echo off | sudo tee /sys/devices/system/cpu/smt/control

# Configure ISST to use
sudo $ISST -c 0-55 core-power assoc --clos 1
sudo $ISST -c 0 core-power assoc --clos 0
sudo $ISST core-power config -c 1 -m 1600
sudo $ISST core-power enable

# Set the FIRESTARTER measurement core to 0
export FIRESTARTER_PERF_CPU=0

# Run each firestarter measurement for 60 seconds and cut away the first and last 5 seconds of the measurement data
START_DELTA=5000
STOP_DELTA=5000
TIMEOUT=60

# column per column on socket 0
alt_order=(0 4 7 11 14 18 21 24 28 32 35 39 42 46 50 53 1 5 8 12 15 19 22 25 29 33 36 40 43 47 51 54 2 6 9 13 16 20 23 26 30 34 37 41 44 48 52 55 3 10 17 27 31 38 45 49)

# Measurement loop. Run all experiments with all number of cores on socket 0.
for ((i = 0 ; i < 56 ; i++)); do
    echo "Running with $i cores."
    if [[ $i -eq 0 ]];
    then
        BINDLIST=0
        ALT_BINDLIST="${alt_order[i]}"
    else
        BINDLIST=0-$i
        ALT_BINDLIST="$ALT_BINDLIST,${alt_order[i]}"
    fi

    # sudo, as we need to access /sys/class/powercap

    # Normal bindlist
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/normal/lic0/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/normal/lic1/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/normal/lic2/$i.csv
    sudo -E $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=L3_L:100         | tail -n 9 > $RESULTS_FOLDER/normal/lic3/$i.csv

    # Alternating bindlist
    sudo -E $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/alt/lic0/$i.csv
    sudo -E $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/alt/lic1/$i.csv
    sudo -E $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/alt/lic2/$i.csv
    sudo -E $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=L3_L:100         | tail -n 9 > $RESULTS_FOLDER/alt/lic3/$i.csv
done