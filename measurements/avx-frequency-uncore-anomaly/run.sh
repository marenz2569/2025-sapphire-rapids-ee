#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname $(readlink -f -- "$0"))

echo "Script is located in $DIR_NAME"

if [ ! -d "$DIR_NAME/dependencies" ]; then
    mkdir dependencies

    cd dependencies

    git clone https://github.com/marenz2569/intel-uncore-freq-dumper

    git clone https://github.com/tud-zih-energy/FIRESTARTER.git


    mkdir intel-uncore-freq-dumper-build
    cd intel-uncore-freq-dumper-build
    cmake ../intel-uncore-freq-dumper -G Ninja
    ninja
    cd ..

    mkdir FIRESTARTER-build
    cd FIRESTARTER-build
    cmake ../FIRESTARTER -G Ninja
    ninja
else
    echo "Skipping dependency download."
fi

IUFD=$DIR_NAME/dependecies/intel-uncore-freq-dumper-build/src/intel-uncore-freq-dumper
FIRESTARTER=$DIR_NAME/dependecies/FIRESTARTER-build/src/FIRESTARTER
ISST=$HOME/linux/tools/power/x86/intel-speed-select/intel-speed-select

cd $DIR_NAME

OUTFOLDER="results/$(hostname)-$(date +"%Y-%m-%d")"

# TODO: remove this once the branch is merged
source ~/lab_management_scripts/.venv/bin/activate
elab frequency 3800
elab ht disable

# Configure ISST to use 
sudo $ISST base-freq disable
sudo $ISST turbo-freq disable
sudo $ISST core-power disable
sudo $ISST -c 0-55 core-power assoc --clos 1
sudo $ISST -c 0 core-power assoc --clos 0
sudo $ISST core-power config -c 1 -m 1600
sudo $ISST core-power enable

BINDLIST=0-7
UNCORE_READER_CORE=8

mkdir -p $OUTFOLDER/{lic0,lic1,lic2,lic3}

for (( i = 0; i < 1000 ; i++ ))
do
    echo "Running iteration $i/1000"
    
    taskset -c $UNCORE_READER_CORE sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic0/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/lic0/firestarter-$i.csv
    wait

    taskset -c $UNCORE_READER_CORE sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic1/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $OUTFOLDER/lic1/firestarter-$i.csv
    wait

    taskset -c $UNCORE_READER_CORE sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic2/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 --run-instruction-groups=REG:100 | tail -n 9 > $OUTFOLDER/lic2/firestarter-$i.csv
    wait

    taskset -c $UNCORE_READER_CORE sudo $IUFD --measurement-interval 1 --measurement-duration 10000 --start-delta 5000 --stop-delta 2000 --outfile $OUTFOLDER/lic3/uncore-freq-$i.csv &
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 --run-instruction-groups=L3_L:100 | tail -n 9 > $OUTFOLDER/lic3/$i.csv
    wait
done

echo "written results to $OUTFILE"
