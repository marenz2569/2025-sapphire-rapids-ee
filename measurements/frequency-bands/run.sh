#!/usr/bin/env bash

echo "it is $(date)"

# TODO: remove this once the branch is merged
source ~/lab_management_scripts/.venv/bin/activate
elab frequency 3800

git clone  https://github.com/travisdowns/avx-turbo.git || true

cd avx-turbo

# latest master version on the time of this commit
git reset --hard 9cfe8bf3089636b98d9a7eaa97b9fef268004a1b

make -j

lsmod | grep -q msr && echo "MSR already loaded" || { echo "Loading MSR module"; sudo modprobe msr ; }

OUTFILE="../results/$(date +"%Y-%m-%d").datafile"

sudo ./avx-turbo --iters=100000 --warmup-ms=1000 | tee $OUTFILE

echo "written results to $OUTFILE"
