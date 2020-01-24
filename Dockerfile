#
# Dockerfile for ISC dhcpd server, initially for piehole rpi, 22-Jan-2020/shj
#
#  $ docker build -t docked-dhcpd .
#
# Exec run-dhcpd-container.sh to start the container.
#

FROM alpine:latest

LABEL ISC DHCP-server with Alpine Linux

MAINTAINER Stig Jacobsen <stighj@gmail.com>

RUN apk add --update bash && \
    apk add dhcp-server-ldap && \
    rm -rf /var/cache/apk/* && \
    echo '*** Packages installed! ***'

USER root

WORKDIR /root

ENV LOGFILE /var/lib/dhcp/logfile

# dhcpd options:
#  -f foreground, so container won't exit
#  -d debug output (logging) to terminal
CMD /usr/sbin/dhcpd -f -d eth0 2>&1 | tee $LOGFILE

#eof#
