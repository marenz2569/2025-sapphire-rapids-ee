#!/usr/bin/env bash

mkdir -p $RESULTS_FOLDER/{lic0,lic1,lic2,lic3} || true

# Take hyperthreads offline
echo off | sudo tee /sys/devices/system/cpu/smt/control

BINDLIST=0-7
UNCORE_READER_CORE=8

mkdir -p $OUTFOLDER/{lic0,lic1,lic2,lic3}

for (( i = 0; i < 100 ; i++ ))
do
    echo "Running iteration $i/100"

    sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration 20000 --start-delta 10000 --stop-delta 2000 --outfile $RESULTS_FOLDER/lic0/uncore-freq-$i.csv &
    sudo $FIRESTARTER -b $BINDLIST --measurement --start-delta=10000 --start-delta=2000 -t 20 -i 6 --run-instruction-groups=REG:100 | tail -n 9 > $RESULTS_FOLDER/lic0/firestarter-$i.csv
    wait

    sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration 20000 --start-delta 10000 --stop-delta 2000 --outfile $RESULTS_FOLDER/lic1/uncore-freq-$i.csv &
    sudo $FIRESTARTER -b $BINDLIST --measurement --start-delta=10000 --start-delta=2000 -t 20 -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/lic1/firestarter-$i.csv
    wait

    sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration 20000 --start-delta 10000 --stop-delta 2000 --outfile $RESULTS_FOLDER/lic2/uncore-freq-$i.csv &
    sudo $FIRESTARTER -b $BINDLIST --measurement --start-delta=10000 --start-delta=2000 -t 20 --run-instruction-groups=REG:100 | tail -n 9 > $RESULTS_FOLDER/lic2/firestarter-$i.csv
    wait

    sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration 20000 --start-delta 10000 --stop-delta 2000 --outfile $RESULTS_FOLDER/lic3/uncore-freq-$i.csv &
    sudo $FIRESTARTER -b $BINDLIST --measurement --start-delta=10000 --start-delta=2000 -t 20 --run-instruction-groups=L3_L:100 | tail -n 9 > $RESULTS_FOLDER/lic3/firestarter-$i.csv
    wait
done