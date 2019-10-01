#!/bin/sh
##################
# USAGE
###################
usage="$(basename "$0") [-h] int rxwarn txwar rxwarn txcrit
A bash script to measurement the bandwidth on an specific network interface. 
Please install vnstat before run this script. 

where:
    -h          show this help text
    int         interface
    rxwarn      download warning
    txwarn      upload warning
    rxcrit      download critical
    txcrit      upload critical"

if [ $# -ne 5 ]; then
	if [ "$1" == "-h" ]; then
		echo "$usage"
		exit $STATE_UNKNOWN
	fi
	echo "Please enter the  int rxwarn txwarn rxcrit txcrit" 
fi
exit $STATE_UNKNOWN
######################
# Variables
######################
INT=$1
WARNLEVEL1=$2
WARNLEVEL2=$3
CRITLEVEL1=$4
CRITLEVEL2=$5
ESCALA=$6
FACTOR=10000000
MEGA=0.0078125
MEGA2=0.0009765625
U=Mbps
M0='Mbit/s'
K1='kB/s'
K2='kbit/s'
#####################
# Salidas Nagios
#####################
UNKNOWN_STATE=3
CRITICAL_STATE=2
WARNING_STATE=1
OK_STATE=0

###################
# Logica
###################
touch /tmp/VNC.txt
vnstat -tr  -i $INT | column | tail -2 > /tmp/VNC.txt
RX=$(head -n 1 /tmp/VNC.txt | awk '{print $2}' | sed 's/,/./')
TX=$(tail -n 1 /tmp/VNC.txt | awk '{print $2}' | sed 's/,/./')

#######################
# Unidades
######################
URX=$(head -n 1 /tmp/VNC.txt | awk '{print $3}')
UTX=$(tail -n 1 /tmp/VNC.txt | awk '{print $3}')

if [ $URX = 'kB/s' ]
	then
	RX1=$(echo "$RX*$MEGA" | bc)
	else if [ $URX = 'kbit/s' ]
	then
	RX1=$(echo "$RX*$MEGA2" | bc)
	else
	RX1=$(echo "$RX")
	fi
fi
if [ $UTX = 'kB/s' ]
        then
       	TX1=$(echo "$TX*$MEGA" | bc)
        else if [ $UTX = 'kbit/s' ]
        then
        TX1=$(echo "$TX*$MEGA2" | bc)
        else
        TX1=$(echo "$TX")
        fi
fi


##########################
# Evaluacion
########################

RX2=$(echo "$RX1*$FACTOR" | bc)
RX3=$(echo ${RX2%.*})
RX4=$(echo `expr substr $RX1 1 4`)
TX2=$(echo "$TX1*$FACTOR" | bc)
TX3=$(echo ${TX2%.*})
TX4=$(echo `expr substr $TX1 1 4`)

RXWARN=$(echo "$WARNLEVEL1*$FACTOR" | bc)
RXWARN2=$(echo ${RXWARN%.*})
TXWARN=$(echo "$WARNLEVEL2*$FACTOR" | bc)
TXWARN2=$(echo ${TXWARN%.*})
RXCRIT=$(echo "$CRITLEVEL1*$FACTOR" | bc)
RXCRIT2=$(echo ${RXCRIT%.*})
TXCRIT=$(echo "$CRITLEVEL2*$FACTOR" | bc)
TXCRIT2=$(echo ${TXCRIT%.*})


#####################
# NOTIFICACION
#####################

if [ -n "$WARNLEVEL1" -a -n "$CRITLEVEL1" ]
then
  	if [ "$RX3" -ge "$RXWARN2" -a "$RX3" -lt "$RXCRIT2" ]
	then
	    echo "WARNING - Los datos recibidos son $RX4 $U | rx=$RX4;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"
		rm -rf /tmp/VNC.txt 
		exit $WARNING_STATE
	elif [ "$RX3" -ge "$RXCRIT2" ]
        then
            echo "CRITICAL - Los datos recibidos son $RX4 $U | rx=$RX4;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"
		 rm -rf /tmp/VNC.txt
	         exit $CRITICAL_STATE
	elif [ "$TX3" -ge "$TXWARN2" -a "$TX3" -lt "$TXCRIT2" ]
        then
            echo "WARNING - Los datos transmitidos son $TX4 $U | rx=$RX1;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"
		 rm -rf /tmp/VNC.txt
                exit $WARNING_STATE
	elif [ "$TX3" -ge "$TXCRIT2" ]
        then
            echo "CRITICAL - Los datos transmitidos son $TX4 $U | rx=$RX1;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"  
		 rm -rf /tmp/VNC.txt
        	exit $CRITICAL_STATE
	else 
		echo "OK - Rx=$RX4 $U y TX=$TX4 $U | rx=$RX4;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"
		 rm -rf /tmp/VNC.txt
		exit $OK_STATE
	fi
else
	echo "OK - Rx=$RX4 $U y TX=$TX4 $U | rx=$RX4;$2;$4;0;$6 tx=$TX4,$3;$5;0;$6"
	 rm -rf /tmp/VNC.txt
	exit $OK_STATE
fi

