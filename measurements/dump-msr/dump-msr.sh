#!/usr/bin/env bash

# Read the Msr space from 0..0x2000
for ((i = 0 ; i < 8192 ; i++)); do
    echo -n "$i: "
    rdmsr -p 0 $i || echo -n '\n'
done
