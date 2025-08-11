#!/usr/bin/env bash

# Take hyperthreads offline
echo off | sudo tee /sys/devices/system/cpu/smt/control

for CPU in `seq 0 111`
do
        EVENTS=cycles
        for CBO in `seq 0 55`
        do
                # TxR_VERT_OCCUPANCY0
                # • Title:
                # • Category: Vertical Egress Events
                # • Event Code: 0x90
                # • Register Restrictions :
                # • Definition: Occupancy event for the egress buffers in the common mesh stop. The
                #   egress is used to queue up requests destined for the vertical ring on the mesh.

                # AD - Agent 0 and AK - Agent 0
                EVENTS="${EVENTS},uncore_cha_${CBO}/event=144,umask=0x03/"
                # TxR_HORZ_OCCUPANCY
                # • Title:
                # • Category: Horizontal Egress Events
                # • Event Code: 0xA0
                # • Register Restrictions :
                # • Definition: Occupancy event for the transgress buffers in the common mesh stop.
                #   The egress is used to queue up requests destined for the horizontal ring on the mesh.

                # AD - Uncredited and AK
                EVENTS="${EVENTS},uncore_cha_${CBO}/event=160,umask=0x03/"

        done

        sudo perf stat -x , -e ${EVENTS} -a --per-socket taskset -c $CPU $STREAM > /dev/null 2>> $RESULTS_FOLDER/$CPU.out
done