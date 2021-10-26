#! /usr/bin/env bash
#Created by: Andrew Dean
#Date created: 26/Oct/2021
#Version: V0.1

NTHCORE=$(lscpu | awk 'NR==3 {print$2}')

echo -e  "                   CORE 0    CORE 1    CORE 2    CORE 3"

for i in /sys/devices/system/cpu/cpu0/cpufreq/{cpuinfo,scaling}_*; do #Iterates through all CPU freq's
	PNAME=$(basename $i)
	[[ "${PNAME}" == *available* ]] || [[ "${PNAME}" == *transition* ]] || \
	[[ "${PNAME}" == *driver* ]] || [[ "${PNAME}" == *setspeed* ]] && continue

	echo "$PNAME: "

	for (( j = 0; j < ${NTHCORE}; j++ ));do
		KPARAM=$(echo $i | sed "s/cpu0/cpu$j/") #Replace cpu0 with cpuj for forloop to work
		sudo cat $KPARAM
	done

done | paste - - - - - | column -t
