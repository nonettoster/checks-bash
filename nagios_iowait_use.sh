#!/bin/sh
##################
# USAGE
###################
usage="$(basename "$0") [-h] int warn crit
A bash script to get the iowait (input/output) value and compare with the thresholds
Please install iostat before run this script. 

where:
    -h          show this help text
    arn      	warning thresholds 
    cit      	critical thresholds"

if [ $# -ne 3 ]; then
	if [ "$1" == "-h" ]; then
		echo "$usage"
		exit $STATE_UNKNOWN
	fi
	echo "Please enter the warn crit values" 
fi
exit $STATE_UNKNOWN

######################
# Variables
######################
WARNLEVEL=$1
CRITLEVEL=$2
FACTOR=100
#####################
# Salidas Nagios
#####################
UNKNOWN_STATE=3
CRITICAL_STATE=2
WARNING_STATE=1
OK_STATE=0

###############
# Print usage
##############
#if [[ $# -ne 2 ]]; then
#        echo -e "INDICAR NIVEL WARNING y NIVEL CRITCO"
#        exit $STATE_UNKNOWN
#fi

###################
# Logica
###################
IOWAIT1=$(iostat -c | column | tail -1 | awk '{print $4}'|sed 's/,/./')
IOWAIT2=$(echo "$IOWAIT1*$FACTOR" | bc)
IOWAIT3=$(echo ${IOWAIT2%.*})

WARNLEVEL1=$(echo "$WARNLEVEL*$FACTOR" | bc)
CRITLEVEL1=$(echo "$CRITLEVEL*$FACTOR" | bc)

###################
# ALERTA
###################

if [ -n "$WARNLEVEL" -a -n "$CRITLEVEL" ]
then
  	if [ "$IOWAIT3" -ge "$WARNLEVEL1" -a "$IOWAIT3" -lt "$CRITLEVEL1" ]
	then 
	    echo "WARNING - EL IOWAIT ES DE $IOWAIT1 | iowait=$IOWAIT1;$1;$2;0;30"
	      exit $WARNING_STATE
	elif [ "$IOWAIT3" -ge "$CRITLEVEL1" ]
	then
            echo "CRITICAL - EL IOWAIT ES DE $IOWAIT1 | iowait=$IOWAIT1;$1;$2;0;30"
	    exit $CRITICAL_STATE
	else
	    echo "OK  - IOWAIT ES DE $IOWAIT1 | iowait=$IOWAIT1;$1;$2;0;30"
	    exit $OK_STATE
	fi
else
	echo "OK  - IOWAIT ES DE $IOWAIT1 | iowait=$IOWAIT1;$1;$2;0;30"
      	exit $OK_STATE
fi 



