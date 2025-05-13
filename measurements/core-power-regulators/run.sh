#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname $(readlink -f -- "$0"))

echo "Script is located in $DIR_NAME"

if [ ! -d "$DIR_NAME/dependencies" ]; then
    mkdir dependencies

    cd dependencies
    git clone https://github.com/tud-zih-energy/FIRESTARTER.git || true

    cd ..
else
    echo "Skipping dependency download."
fi

cd $DIR_NAME/dependencies/FIRESTARTER

git fetch

# TODO: change this to master. This is currently the version of PR 115
git reset --hard f4675a46e6acd59101ef9baae7f3a11712cafa8e

mkdir -p $DIR_NAME/dependencies/FIRESTARTER-build || true

cd $DIR_NAME/dependencies/FIRESTARTER-build

cmake ../FIRESTARTER -G Ninja
ninja

cd $DIR_NAME

OUTFOLDER="results/$(date +"%Y-%m-%d")"

mkdir -p $OUTFOLDER/{rows,columns} || true

FIRESTARTER=$DIR_NAME/dependencies/FIRESTARTER-build/src/FIRESTARTER

# TODO: remove this once the branch is merged
source ~/lab_management_scripts/.venv/bin/activate
elab ht enable
# Set core frequency fixed to 1GHz
elab frequency 1000
elab ht disable
# Set uncore frequency fixed to 1GHz
sudo wrmsr -a 0x620 0x0a0a

sudo modprobe intel_rapl_msr

# column per column on hati's socket 0
alt_order=(0 4 7 11 14 18 21 24 28 32 35 39 42 47 50 53 1 5 8 12 15 19 22 25 29 33 36 40 43 47 51 54 2 6 9 13 15 20 23 26 30 34 37 40 44 48 52 55 3 10 17 27 31 38 45 49)

# Measurement loop. Run all experiments with all number of cores on socket 0.
for ((i = 0 ; i < 56 ; i++)); do
    echo "Running with $i cores."
    # Measure 30 seconds, discarding the first 15 and last 2 seconds
    if [[ $i -eq 0 ]];
    then
        ROWS_BINDLIST=0
	COLUMNS_BINDLIST="${alt_order[i]}"
    else
        ROWS_BINDLIST=0-$i
	COLUMNS_BINDLIST="$COLUMNS_BINDLIST,${alt_order[i]}"
    fi
    # we need to access /sys/class/powercap
    sudo $FIRESTARTER -b $ROWS_BINDLIST --measurement --start-delta=15000 --start-delta=2000 -t 30 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/rows/$i.csv
    sudo $FIRESTARTER -b $COLUMNS_BINDLIST --measurement --start-delta=15000 --start-delta=2000 -t 30 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/columns/$i.csv
done

echo "written results to $OUTFOLDER"
