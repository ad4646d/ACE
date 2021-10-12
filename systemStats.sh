#! /usr/bin/
# CREATED BY: Andrew Dean
# Date created: 12/Oct/2021
# Version: V0.2

# This script is designed to gather system statistics
AUTHOR="Andrew Dean"
VERSION="V0.2"
RELEASED="2021-10-12"

# Display a help message

USAGE(){
	echo -e $1
	echo -e "\nUsage: systemStats [-t temperature] [-i ipv4 address] [-c cpu usage]"
	echo -e "\t\t [-v version]"
	echo -e "\t\t For more information - see man systemStats"

}

# Check for arguments (error checking)
if [ $# -lt 1 ];then
	USAGE "Not enough arguments."
	exit 1
elif [ $# -gt 3 ];then
	USAGE "Too many arguments."
	exit 1
elif [[ (  $1 == '-h' ) || ( $# == '--help' ) ]];then
	USAGE "Help!"
	exit 1
fi

# Frequently scripts are written so that arguments can be passed in any order using 'flags'
# With the flags method, some of the arguments can be made mandatory or optional
# EXAMPLE - a:b (a is mandatory, whereas b is optional) abc is all optional

while getopts ctiv OPTION
do
case ${OPTION}
in
i) IP=$(ifconfig wlan0 | grep -w inet | awk '{print$2}')
   echo ${IP};;
c) USAGE=$(grep -w 'cpu' /proc/stat | awk '{usage=($2+$3+$4+$6+$7+$8)*100/($2+$3+$4+$5+$6+$7+$8)}
					   {free=($5)*100/($2+$3+$4+$5+$6+$7+$8)}
					    END {printf "Used CPU: %.2f%%\n",usage}
						{printf "Free CPU: %.2f%%\n", free}')
   echo ${USAGE};;
t) TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
   echo ${TEMP} "Need to divide by 1000 to get degC.";;
v) echo -e "systemStats:\n\t Version: ${VERSION} Released on: ${RLEASED} Created by: ${AUTHOR}";;
esac
done


# End of script
