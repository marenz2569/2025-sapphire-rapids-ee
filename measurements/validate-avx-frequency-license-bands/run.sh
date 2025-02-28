#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname $(readlink -f -- "$0"))

echo "Script is located in $DIR_NAME"

# Download libnl-3 dependencies
if [ ! -d "$DIR_NAME/dependencies" ]; then
    mkdir dependencies

    cd dependencies

    wget http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-3-dev_3.5.0-0.1_amd64.deb
    wget http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-genl-3-dev_3.5.0-0.1_amd64.deb
    wget http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-genl-3-200_3.5.0-0.1_amd64.deb
    wget http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-3-200_3.5.0-0.1_amd64.deb

    ar x libnl-3-dev_3.5.0-0.1_amd64.deb
    tar xvf data.tar.zst

    ar x libnl-genl-3-dev_3.5.0-0.1_amd64.deb
    tar xvf data.tar.zst

    ar x libnl-genl-3-200_3.5.0-0.1_amd64.deb
    tar xvf data.tar.zst

    ar x libnl-3-200_3.5.0-0.1_amd64.deb
    tar xvf data.tar.zst

    git clone https://github.com/tud-zih-energy/FIRESTARTER.git || true

    cd ..
else
    echo "Skipping dependency download."
fi

cd $HOME

git clone https://github.com/torvalds/linux.git || true

cd linux

# latest intel-speed-select release v1.21
git reset --hard 600c8f24319cebe671a70722df99b8006daebe21

git apply $DIR_NAME/sapphire_rapids_fixes.patch

cd tools/power/x86/intel-speed-select

export CFLAGS=-I$DIR_NAME/dependencies/usr/include/libnl3
export LDFLAGS=-L$DIR_NAME/dependencies/lib/x86_64-linux-gnu
make clean
make -j

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

mkdir -p $OUTFOLDER/{lic0,lic1,lic2,lic3} || true

ISST=$HOME/linux/tools/power/x86/intel-speed-select/intel-speed-select
FIRESTARTER=$DIR_NAME/dependencies/FIRESTARTER-build/src/FIRESTARTER

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
sudo $ISST core-power config -c 1 -m 1000
sudo $ISST core-power enable

# Set the FIRESTARTER measurement core to 0
export FIRESTARTER_PERF_CPU=0

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
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=30000 --start-delta=5000 -t 60 -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $OUTFOLDER/lic0/$i.csv
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=30000 --start-delta=5000 -t 60 -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $OUTFOLDER/lic1/$i.csv
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=30000 --start-delta=5000 -t 60 --run-instruction-groups=REG:100 | tail -n 9 > $OUTFOLDER/lic2/$i.csv
    $FIRESTARTER -b $BINDLIST --measurement --start-delta=30000 --start-delta=5000 -t 60 --run-instruction-groups=L3_L:100 | tail -n 9 > $OUTFOLDER/lic3/$i.csv
done

# Reset ISST
sudo $ISST core-power disable

echo "written results to $OUTFOLDER"

