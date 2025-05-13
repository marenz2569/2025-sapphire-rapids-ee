#!/bin/sh

HOSTNAME=`hostname`

echo $HOSTNAME

rm ./find_event_${HOSTNAME}

for CPU in `seq 0 103`
do



EVENTS=cycles
for CBO in `seq 1 59`
do
	# measure up/down
	EVENTS="${EVENTS},uncore_cha_${CBO}/event=144,umask=0x03/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=144,umask=0x0C/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=160,umask=0x03/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=160,umask=0x0C/"

done

echo "CPU $CPU Event ${TEST_EVENT}" >> ./find_event_${HOSTNAME}
sudo perf stat -x , -e ${EVENTS} -a --per-socket taskset -c $CPU ./stream > /dev/null 2>> ./find_event_${HOSTNAME}

done


