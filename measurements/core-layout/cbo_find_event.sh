#!/bin/sh

HOSTNAME=`hostname`

echo $HOSTNAME

rm ./find_event_${HOSTNAME} || true

for CPU in `seq 0 55`
do



EVENTS=cycles
for CBO in `seq 0 55`
do
	# measure up/down
	EVENTS="${EVENTS},uncore_cha_${CBO}/event=144,umask=0x03/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=144,umask=0x0C/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=160,umask=0x03/"
        EVENTS="${EVENTS},uncore_cha_${CBO}/event=160,umask=0x0C/"

done

echo "CPU $CPU Event" >> ./find_event_${HOSTNAME}
sudo perf stat -x , -e ${EVENTS} -a --per-socket taskset -c $CPU ./stream > /dev/null 2>> ./find_event_${HOSTNAME}

done


