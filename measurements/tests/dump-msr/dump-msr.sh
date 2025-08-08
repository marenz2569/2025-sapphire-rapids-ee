#!/usr/bin/env bash

# Read the Msr space from 0..0xffffffff
for ((i = 0 ; i < 4294967296 ; i++)); do
    echo -n "$i: "
    rdmsr -p 0 $i || echo ""
done
