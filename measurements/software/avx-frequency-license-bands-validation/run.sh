#!/usr/bin/env bash

mkdir -p $RESULTS_FOLDER/{normal,alt}/{lic0,lic1,lic2,lic3} || true

echo 0 | sudo tee /sys/devices/system/cpu/cpu*/cpuidle/*/disable

echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq
echo off | sudo tee /sys/devices/system/cpu/smt/control

# Configure ISST to use
sudo $ISST base-freq disable
sudo $ISST turbo-freq disable
sudo $ISST core-power disable
sudo $ISST -c 0-55 core-power assoc --clos 1
sudo $ISST -c 0 core-power assoc --clos 0
sudo $ISST core-power config -c 1 -m 1600
sudo $ISST core-power enable

# Set the FIRESTARTER measurement core to 0
export FIRESTARTER_PERF_CPU=0

# Run each firestarter measurement for 10 seconds and cut away the first 5 and last 2 seconds of the measurement data
START_DELTA=5000
STOP_DELTA=2000
TIMEOUT=10

# populate alternating over the tiles of socket 0
# python3 -c 'print(" ".join([ str(14*i + j) for j in range(14) for i in range(4) ]))'
alt_order=(0 14 28 42 1 15 29 43 2 16 30 44 3 17 31 45 4 18 32 46 5 19 33 47 6 20 34 48 7 21 35 49 8 22 36 50 9 23 37 51 10 24 38 52 11 25 39 53 12 26 40 54 13 27 41 55)

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

    # Normal bindlist
    $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/normal/lic0/$i.csv
    $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/normal/lic1/$i.csv
    $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/normal/lic2/$i.csv
    $FIRESTARTER -b $BINDLIST     --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=L3_L:100         | tail -n 9 > $RESULTS_FOLDER/normal/lic3/$i.csv

    # Alternating bindlist
    $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/alt/lic0/$i.csv
    $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/alt/lic1/$i.csv
    $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=REG:100          | tail -n 9 > $RESULTS_FOLDER/alt/lic2/$i.csv
    $FIRESTARTER -b $ALT_BINDLIST --measurement --start-delta=$START_DELTA --stop-delta=$STOP_DELTA -t $TIMEOUT      --run-instruction-groups=L3_L:100         | tail -n 9 > $RESULTS_FOLDER/alt/lic3/$i.csv
done

# Reset ISST
sudo $ISST core-power disable

echo on | sudo tee /sys/devices/system/cpu/smt/control
echo 800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq
echo 3800000 | sudo tee /sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor