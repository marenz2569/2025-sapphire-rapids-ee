#!/usr/bin/env bash

core_frequencies=(800 1600 2000 performance)
uncore_frequencies=(0x0808 0x1010 0x1919 0x0819)

# Run each firestarter measurement for 60 seconds and cut away the first and last 5 seconds of the measurement data
START_DELTA=5000
STOP_DELTA=5000
TIMEOUT=60
IUFD_TIMEOUT=$(echo "$TIMEOUT * 1000" | bc)
UNCORE_READER_CORE=0

# Measurement loop. Run all experiments with all number of cores on socket 0.
for core_frequency in "${core_frequencies[@]}"; do
    for uncore_frequency in "${uncore_frequencies[@]}"; do
        mkdir -p $RESULTS_FOLDER/$core_frequency/$uncore_frequency/{lic0,lic1,lic2,lic3} || true

        elab frequency $core_frequency
        sudo wrmsr -a 0x620 $uncore_frequency

        for ((i = 0 ; i < 56 ; i++)); do
            echo "Running with $i cores."
            if [[ $i -eq 0 ]];
            then
                BINDLIST=0
            else
                BINDLIST=0-$i
            fi

            # we need to access /sys/class/powercap
            sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration $IUFD_TIMEOUT --start-delta $START_DELTA --stop-delta $STOP_DELTA --outfile $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic0/uncore-freq-$i.csv &
            sudo -E $FIRESTARTER -b $BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100  | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic0/firestarter-$i.csv
            wait

            sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration $IUFD_TIMEOUT --start-delta $START_DELTA --stop-delta $STOP_DELTA --outfile $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic1/uncore-freq-$i.csv &
            sudo -E $FIRESTARTER -b $BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT -i 6 --run-instruction-groups=REG:100,L1_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic1/firestarter-$i.csv
            wait

            sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration $IUFD_TIMEOUT --start-delta $START_DELTA --stop-delta $STOP_DELTA --outfile $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic2/uncore-freq-$i.csv &
            sudo -E $FIRESTARTER -b $BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=REG:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic2/firestarter-$i.csv
            wait

            sudo taskset -c $UNCORE_READER_CORE sudo $IUFD --use-sysfs --measurement-interval 10 --measurement-duration $IUFD_TIMEOUT --start-delta $START_DELTA --stop-delta $STOP_DELTA --outfile $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic3/uncore-freq-$i.csv &
            sudo -E $FIRESTARTER -b $BINDLIST --measurement --start-delta=$START_DELTA --start-delta=$STOP_DELTA -t $TIMEOUT --run-instruction-groups=L3_L:100 | tail -n 9 > $RESULTS_FOLDER/$core_frequency/$uncore_frequency/lic3/firestarter-$i.csv
            wait
        done
    done
done