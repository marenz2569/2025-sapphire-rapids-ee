#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname $(readlink -f -- "$0"))

echo "Script is located in $DIR_NAME"

cd $DIR_NAME/dependencies/FIRESTARTER

git pull

# TODO: change this to master. This is currently the version of PR 115
git reset --hard f4675a46e6acd59101ef9baae7f3a11712cafa8e

mkdir -p $DIR_NAME/dependencies/FIRESTARTER-build || true

cd $DIR_NAME/dependencies/FIRESTARTER-build

cmake ../FIRESTARTER -G Ninja
ninja

cd $DIR_NAME

OUTFOLDER="results/$(date +"%Y-%m-%d")"

FIRESTARTER=$DIR_NAME/dependencies/FIRESTARTER-build/src/FIRESTARTER

# TODO: remove this once the branch is merged
source ~/lab_management_scripts/.venv/bin/activate
elab frequency 1000
elab ht enable

# Measurement loop. Run all experiments with all number of cores on socket 0.
for ((i = 0 ; i < 56 ; i++)); do
    echo "Running with $i cores."
    # Measure 30 seconds, discarding the first 15 and last 2
    if [[ $i -eq 0 ]];
    then
        BINDLIST=0
    else
        BINDLIST=0-$i
    fi
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=5000 --start-delta=2000 -t 10 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/$i.csv
done

echo "written results to $OUTFOLDER"
