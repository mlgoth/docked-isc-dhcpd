#!/bin/bash
# Start ISC DHCP-server docker container, part of docked-isc-dhcpd, 22-Jan-2020/shj

DATA=$HOME/.dhcpd-data              # leases and logfiles on host
LOGFILE=$DATA/logfile               # output from dhcpd

if [ ! -d $DATA ]; then
   mkdir $DATA
   touch $DATA/dhcpd.leases         # dhcpd won't start unless this exists
   echo Created directory $DATA
fi

if [ -f $LOGFILE ]; then            # rotate logfile on every container start
   mv -f $LOGFILE $LOGFILE.old
fi

# Get the last changes if needed (dev only)
time docker build -t docked-dhcpd .

docker run --rm \
           --detach \
           --network host \
           -v /etc/dhcp/dhcpd.conf:/etc/dhcp/dhcpd.conf \
           -v $DATA:/var/lib/dhcp \
           -v /etc/localtime:/etc/localtime:ro \
           --name dhcpd \
           docked-dhcpd

exit 0
