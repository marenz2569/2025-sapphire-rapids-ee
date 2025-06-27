#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname $(readlink -f -- "$0"))

echo "Script is located in $DIR_NAME"

if [ ! -d "$DIR_NAME/dependencies" ]; then
    mkdir dependencies

    cd dependencies

    git clone https://github.com/marenz2569/intel-uncore-freq-dumper

    mkdir intel-uncore-freq-dumper-build
    cd intel-uncore-freq-dumper-build
    cmake ../intel-uncore-freq-dumper -G Ninja
    ninja
    cd ..
else
    echo "Skipping dependency download."
fi


cd $DIR_NAME

OUTFOLDER="results/$(hostname)-$(date +"%Y-%m-%d")"

IUFD=$DIR_NAME/dependecies/intel-uncore-freq-dumper-build/src/intel-uncore-freq-dumper

BINDLIST=2

for (( i = 0; i < 1000 ; i++ ))
do
    taskset -c 1 sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic0/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/lic0/firestarter-$i.csv
    wait

    taskset -c 1 sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic1/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $OUTFOLDER/lic1/firestarter-$i.csv
    wait

    taskset -c 1 sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic2/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 --run-instruction-groups=REG:100 | tail -n 9 > $OUTFOLDER/lic2/firestarter-$i.csv
    wait

    taskset -c 1 sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic3/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 --run-instruction-groups=L3_L:100 | tail -n 9 > $OUTFOLDER/lic3/$i.csv
    wait
done

echo "written results to $OUTFILE"
