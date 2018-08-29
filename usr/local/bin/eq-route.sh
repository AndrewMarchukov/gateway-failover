#!/bin/bash
#2 providers on the same gateway load balancing* and failover
#Create script which will ping every 5 second popular resources on the Internet:
#/usr/local/bin/eq-route.sh
#Make it executable: chmod +x /usr/local/bin/eq-route.sh
#*Note that balancing will not be perfect, as it is route based, and routes are cached. This means that routes to often-used sites will always be over the same provider.

while sleep 5

do

ONE_GATEWAY="1.1.1.1"   # Default Gateway

SEC_GATEWAY="2.2.2.2"   # Backup Gateway, example pppoe SEC_GATEWAY=$(ifconfig ppp0 | awk '/destination/ { print $6 }')

RMT_IP_1="77.88.8.8"    # First remote ping ip

RMT_IP_2="8.8.4.4"      # Second remote ping ip

PING_TIMEOUT="1"        # Ping timeout in seconds

FAILOVER_PAUSE="1800"   # Wait 30 minutes after failover

INT1=eth1 # name first external interface

INT2=eth2 # name second external interface

#This will balance the routes over both providers. The weight parameters can be tweaked to favor one provider over the other.
WEIGHT1=1 # first provider weight

WEIGHT2=1 # second provider weight

DEFROUTE=`ip route |grep nexthop |cut -d " " -f5|tr -d "\n"`

DIFROUTE=`ip route |grep default| cut -d ' ' -f5`

# check user

if [ `whoami` != "root" ]

then

    echo "Failover script must be run as root!"

    exit 1

fi

    ip route add $RMT_IP_1 via $ONE_GATEWAY dev $INT1

    ip route add $RMT_IP_2 via $ONE_GATEWAY dev $INT1

    ping -c 2 -I $INT1 -W $PING_TIMEOUT $RMT_IP_1 > /dev/null

    PING_1=$?

    ping -c 2 -I $INT1 -W $PING_TIMEOUT $RMT_IP_2 > /dev/null

    PING_2=$?



ip route del $RMT_IP_1

ip route del $RMT_IP_2



    ip route add $RMT_IP_1 via $SEC_GATEWAY dev $INT2

    ip route add $RMT_IP_2 via $SEC_GATEWAY dev $INT2

    ping -c 2 -I $INT2 -W $PING_TIMEOUT $RMT_IP_1 > /dev/null

    PING_3=$?

    ping -c 2 -I $INT2 -W $PING_TIMEOUT $RMT_IP_2 > /dev/null

    PING_4=$?



ip route del $RMT_IP_1

ip route del $RMT_IP_2



if [[ ( "$PING_1" == "0" || "$PING_2" == "0" ) && ( "$PING_3" == "0" || "$PING_4" == "0" ) ]]; then

if [ "$DEFROUTE" != "$INT1$INT2" ]; then

ip route del default

ip route add default scope global nexthop via $ONE_GATEWAY dev $INT1 weight $WEIGHT1 nexthop via $SEC_GATEWAY dev $INT2 weight $WEIGHT2

echo "CHANGE EQ ROUTE"

fi

elif [[ ( "$PING_1" == "0" && "$DIFROUTE" != "$INT1" ) || ( "$PING_2" == "0" && "$DIFROUTE" != "$INT1" ) ]]

then

ip route del default

ip route add default via $ONE_GATEWAY

echo "CHANGE $ONE_GATEWAY"

sleep $FAILOVER_PAUSE

elif [[ ( "$PING_3" == "0" && "$DIFROUTE" != "$INT2" ) || ( "$PING_4" == "0" && "$DIFROUTE" != "$INT2" ) ]]

then

ip route del default

ip route add default via $SEC_GATEWAY

echo "CHANGE $SEC_GATEWAY"

sleep $FAILOVER_PAUSE

fi

done
