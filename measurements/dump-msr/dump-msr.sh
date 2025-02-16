#!/usr/bin/env bash

# Read the Msr space
for ((i = 0 ; i < 10 ; i++)); do
	echo -n "$i: "
    rdmsr -p 0 $i || true
done
