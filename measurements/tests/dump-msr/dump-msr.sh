#!/usr/bin/env bash

# Read the Msr space from 0..0xffff
for ((i = 0 ; i < 65535 ; i++)); do
    echo -n "$i: "
    rdmsr -p 0 $i || echo ""
done
