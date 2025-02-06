#!/usr/bin/env bash

echo "it is $(date)"

git clone  https://github.com/travisdowns/avx-turbo.git || true

cd avx-turbo

# latest master version on the time of this commit
git reset --hard 9cfe8bf3089636b98d9a7eaa97b9fef268004a1b

make -j

lsmod | grep -q msr && echo "MSR already loaded" || { echo "Loading MSR module"; sudo modprobe msr ; }

sudo ./avx-turbo