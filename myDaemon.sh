#!/usr/bin/env bash
#Created by: Andrew Dean
#Date Created: 2021-11-02

DAEMONNAME="MY-DAEMON"

# $$ is the process ID (PID) of the script itself
MYPID=$$
# Gets the directory path for the script
PIDDIR="$(dirname "$(BASH_SOUCE[0]")"
PIDFILE="${PIDDIR}/${DAEOMNNAME}.pid"

LOGDIR="$(dirname "${BASH_SOURCE[0]}")"

LOGFILE="${LOGDIR}/${DAEMONNAME}.log"

LOGMAXSIZE=1024 #1MB

RUNINTERVAL=60 #Seconds 

doCommands() {
	echo "Running commands."
	log '*** '$(date+"%FT%R:%SZ")": AN IMPORTANT MESSAGE OR LOG DETAIL..."
}

####################################################################################
#                                                                                  #
# Below is the template functionality of the daemon.                               #
#                                                                                  #
####################################################################################

setupDaemon() {
	# Makesure that the directory exist
	if [[ ! -d "${PIDDIR}" ]]; then
		mkdir "${PIDDIR}"
	fi

	if [[ ! -d "${LOGDIR}" ]]; then
		mkdir "${LOGDIR}"
	fi

	if [[ ! -f "${LOGFILE}" ]]; then
		touch "${LOGFILE}"
	else
		#Check to see if  we need to rotate log file
		SIZE=$(( $stat --printf="%s" "${LOGFILE}") / 1-24))
		if [[ ${SIZE} -gt ${LOGMAXSIZE} ]]; then
			mv ${LOGFILE} "$LOGFILE.$(date +%FT%R:%SZ).old"
			touch "${LOGFILE}"
		fi
	fi
}

startDaemon() {
	setupDaemon
	if ! checkDaemon; then
		echo 1>&2 "Error: ${DAEMONNAME} is already running."
		log '*** '$(date+"%FT%R:%SZ")": $USER already running ${DAEMONNAME} PID "$(cat ${PIDFILE})
		exit 1
	fi

	echo " * starting ${DAEMONNAME} with ${MYPID}"
	echo "${MYPID}" > "${PIDFILE}"
	log '*** '$(date+"%FT%R:%SZ")": $USER starting up ${MYDAEMON} PID : ${MYPID}"

	loop
}

stopDaemon() {
	if checkDaemon; then
		echo 1>&2 " * Error: ${DAEMONNAME} is not running."
		exit 1
	fi

	echo " * Stopping ${DAEMONNAME}"

	if [[ ! -z $(cat "${PIDFILE}") ]]; then
		kill -9 $(cat "${PIDFILE}" &> /dev/null)
		log '*** '$(date+"%FT%R:%SZ")": ${DAEMONNAME} stopped."
	else
		echo 1>&2 "Cannot find PID of running daemon."
	fi
}

statusDaemon() {
	# Query and return whether the daemon is running.
	if ! checkDaemon; then
		echo " * ${DAEMONNAME} is running."
		log '*** '$(date+"%FT%R:%SZ")": ${DAEMONNAME} $USER checked status - Running with PID: ${MYPID}"
	else
		echo " * ${DAEMONNAME} isn't running."
		log '*** '$(date+"%FT%R:%SZ")": ${DAEMONNAME} $USER checked status - Not running."
	fi
	exit 0
}

restartDaemon() {
	# Restart the daemon
	if checkDaemon; then
		echo " * ${DAEMONNAME} isn't running."
		log '*** '$(date+"%FT%R:%SZ") ": ${DAEMONNAME} $USER restarted."
		exit 1
	fi
	stopDaemon
	startDaemon
}

checkDaemon() {
	# Checks to see if the daemon is running
	if [[ -z "${OLDPID}" ]]; then
		return 0
	elif ps -ef | grep "${OLDPID}" | grep -v grep &> /dev/null ; then
		if [[ -f "${PIDFILE}" && $(cat "${PIDFILE}") -eq ${OLDPID} ]]; then
		# Daemon is running.
			return 1
		else
			return 0
		fi
	elif ps -ef | grep "${DAEMONNAME}" | grep -v grep | grep -v "{MYPID}" |
	grep -v "0:00.00" | grep bash $> /dev/null ; then
	# Daemon is running but without correct PID, restart it.
		log '*** '$(date+"%FT%R:%SZ")": ${DAEMONNAME} running with invalid PID: restarting..."
		restartDaemon
		return 1
	else
		# Daemon not running
		return 0
	fi
	return 1
}

loop() {
	while true; do
		doCommands
		sleep 60
	done
}

log() {
	# Generic log function
	echo  "$1" >> "${LOGFILE}"
}

###########################
#
# Parse the command.
#
###########################

if [[ -f "${PIDFILE}" ]]; then
	OLDPID=$(cat "${PIDFILE}")
fi

checkDaemon

case "$1" in
	start)
		startDaemon
		;;
	stop)
		stopDaemon
		;
	status)
		statusDaemon
		;;
	restart)
		restartDaemon
		;;
	*)
	echo 1>&2 " * Error: usage $0 { start | stop | status | restart }"
	exit 1
esac

exit 0
