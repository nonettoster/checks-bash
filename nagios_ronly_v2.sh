#!/bin/bash
############
##################
# USAGE
###################
usage="$(basename "$0") [-h] 
A bash script to check that mount points are writable
Instruccions: 
Instruccions:
1) Create a file called "test.txt" in every mount point declared in /proc/mounts
2) Give to nagios-nrpe user's (nrpe by default) the permissions to can write and read the file "test.txt""

if [ $# -ne 0 ]; then
        if [ "$1" == "-h" ]; then
                echo "$usage"
                exit $STATE_UNKNOWN
        fi
        echo "Please enter the  int rxwarn txwarn rxcrit txcrit" 
fi
exit $STATE_UNKNOWN
############
FILE=test.txt
#####################
# Salidas Nagios
#####################
UNKNOWN_STATE=3
CRITICAL_STATE=2
WARNING_STATE=1
OK_STATE=0


###################
# Ejecucion
###################
FECHA=$(date +%H:%M:%S)
PART=$(cat /proc/mounts | grep -e "ext[2-4]" -e "xfs" |  awk -F " " '{print $2}' | sort | uniq | egrep -v "/proc|/sys|/boot|/selinux")
	for LINEA in $PART
	do
		cd $LINEA
		RO=$(echo $FECHA > $LINEA/$FILE > /dev/null 2>&1 ; echo $?)
		#RO=$(touch $FILE > /dev/null 2>&1 ; echo $?)
			if [ "$RO" -eq "0" ]
			then
                	echo > $LINEA/$FILE
        		else
        		echo "CRTICAL - La particion $LINEA esta solo lectura" 
	        	exit $CRITICAL_STATE
			fi
		done 
		echo "OK - El disco no tiene problemas de R/W"
        	exit $OK_STATE
	exit
