#!/usr/bin/env bash

core_frequencies=(800 1600 2000 performance)
uncore_frequencies=(0x0808 0x1010 0x1919 0x0819)

# populate alternating over the tiles of socket 0
# python3 -c 'print(" ".join([ str(14*i + j) for j in range(14) for i in range(4) ]))'
alt_order=(0 14 28 42 1 15 29 43 2 16 30 44 3 17 31 45 4 18 32 46 5 19 33 47 6 20 34 48 7 21 35 49 8 22 36 50 9 23 37 51 10 24 38 52 11 25 39 53 12 26 40 54 13 27 41 55)

# Run each firestarter measurement for 60 seconds and cut away the first and last 5 seconds of the measurement data
START_DELTA=5000
STOP_DELTA=5000
TIMEOUT=60

# Measurement loop. Run all experiments with all number of cores on socket 0.
for core_frequency in "${core_frequencies[@]}"; do
    for uncore_frequency in "${uncore_frequencies[@]}"; do
        mkdir -p $RESULTS_FOLDER/$core_frequency/$uncore_frequency/{rows,columns}/{lic0,lic1,lic2,lic3} || true

        elab frequency $core_frequency
        sudo wrmsr -a 0x620 $uncore_frequency

        for ((i = 0 ; i < 56 ; i++)); do
            echo "Running with $i cores."
            if [[ $i -eq 0 ]];
            then
                ROWS_BINDLIST=0
                COLUMNS_BINDLIST="${alt_order[i]}"
            else
                ROWS_BINDLIST=0-$i
                COLUMNS_BINDLIST="$COLUMNS_BINDLIST,${alt_order[i]}"
            fi

            # we need to access /sys/class/powercap
            sudo $FIRESTARTER -b $ROWS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/rows/lic0/$i.csv
            sudo $FIRESTARTER -b $ROWS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/rows/lic1/$i.csv
            sudo $FIRESTARTER -b $ROWS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=REG:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/rows/lic2/$i.csv
            sudo $FIRESTARTER -b $ROWS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=L3_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/rows/lic3/$i.csv

            sudo $FIRESTARTER -b $COLUMNS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/columns/lic0/$i.csv
            sudo $FIRESTARTER -b $COLUMNS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/columns/lic1/$i.csv
            sudo $FIRESTARTER -b $COLUMNS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=REG:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/columns/lic2/$i.csv
            sudo $FIRESTARTER -b $COLUMNS_BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=L3_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/columns/lic3/$i.csv
        done
    done
done