#!/usr/bin/env bash
#Created by: Andrew Dean
#Date created: 14th Dec '21
#Description: Shell script for rotating log files

LOGPATH="$HOME/ACE/log/yule.log"

logger()
{
	LOGTIME=$(date "+%Y%m%dT%H%M%SZ") # ISO 8601 STANDARD
	USR=$(whoami)
	IP=$(hostname -I | awk '{print$3}')
	
	echo "[ ${LOGTIME} ] [ ${USR} ] [ ${IP} ] $1 $2"  >> ${LOGPATH}
}

resetLog()
{
	echo "" > ${LOGPATH}
	logger "ace:resetLog" "cleaning log file"
}

rotateLogs()
{
	LEN=$(wc -l ${LOGPATH} | awk '{print$1}')
	if [[ ${LEN} -gt 200 ]]; then
		mv ${LOGPATH}.2.gz ${LOGPATH}.3.gz || continue
		mv ${LOGPATH}.1.gz ${LOGPATH}.2.gz || continue
		logger "ace:rotateLogs" "rotating log, shifting by 1."
		gzip -c ${LOGPATH} > ${LOGPATH}.1.gz
		resetLog
	fi
}

test()
{
	for i in  {0..180..1} #{start..end..increment} 
	do
		logger "ace:test" "number $i"
	done
}
logger "ace:logger" "null"
logger "ace:test" "starting test function"
test
logger "ace:test" "finished test function"
logger "ace:test" "checking if log needs rotating..."
rotateLogs
