#!/usr/bin/env bash

echo "it is $(date)"

DIR_NAME=$(dirname "$0")

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
make -j

cd $DIR_NAME

OUTFILE="results/$(date +"%Y-%m-%d").datafile"

ISST=$HOME/linux/tools/power/x86/intel-speed-select/intel-speed-select

sudo $ISST perf-profile list | tee $OUTFILE

echo "written results to $OUTFILE"

CFLAGS=-I/home/s2599166/2025-diploma-thesis/measurements/isst/usr/include/libnl3 LDFLAGS=-L/home/s2599166/2025-diploma-thesis/measurements/isst/lib/x86_64-linux-gnu