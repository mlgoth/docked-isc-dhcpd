
docked-isc-dhcpd/README.md
==========================

This is a Dockerfile and a shell-script to run an ISC DHCP-server in a Docker
container. Thanks to being based on Alpine Linux, the storage required is less
than 25MB for the container image, whereas the running container requires just
about 3MB of ram.


Configuration file
------------------
The DHCP server configuration file is `/etc/dhcp/dhcpd.conf` on both the host and
in the container. It can be edited from either - restart the container to
reload configuration:

```
   $ docker exec -it dhcpd vi /etc/dhcp/dhcpd.conf
   $ docker restart dhcpd
```

Editing the configuration from the host:

```
   host$ sudo vi /etc/dhcp/dhcpd.conf && docker restart dhcpd
```

`/etc/dhcp/dhcpd.conf` must exist before starting the container. A sample one is
provided when you clone from git - copy it to `/etc/dhcp/dhcpd.conf` and edit
it to suit your setup. Updating the first subnet range declaration in the
example file to match your local network will be sufficient to get your own
DHCP-server up and running.


Starting the container
----------------------
Run the startup script as an ordinary user, who is a member of the docker
group:
```
   $ ./run-dhcpd-container.sh
```
The script will create ~/.dhcpd-data/ on first run. View the container output:
```
   $ docker logs -f dhcpd
```
You should see log messages from dhcpd on the terminal and soon it'll be ready
to receive DHCP requests from the network.

Proceed to Testing it below or press ctrl-C to exit to the shell.


Testing and debugging
---------------------
Turn off wifi on your phone, then turn it on again. Container output will be
similar to this as the phone requests a new IP-address:
```
   DHCPREQUEST for 192.168.1.96 from 4c:d1:a1:fc:94:e5 via eth0
   DHCPACK on 192.168.1.96 to 4c:d1:a1:fc:94:e5 via eth0
```
For more testing, run nmap from a Linux host on the same LAN:
```
   $ sudo nmap --script broadcast-dhcp-discover
```
Container log output from the nmap probe will look like:
```
   DHCPDISCOVER from de:ad:c0:de:ca:fe via eth0
   DHCPOFFER on 192.168.1.200 to de:ad:c0:de:ca:fe via eth0
```

Starting after reboot
---------------------
Add the container run script to the users crontab on the host:
```
   $ crontab -e            # add the below line in your crontab editor

   @reboot docked-isc-dhcpd/run-dhcpd-container.sh
```

Logfile
-------
Output from dhcpd is logged to `/var/lib/dhcp/logfile` in the container and
is rotated to .old on every container restart.

The logfile can also be followed from the host with less(1):
```
   host$ less +F ~/.dhcpd-data/logfile
```

Example dhcpd/container startup output
--------------------------------------
```
   # dhcpd -f -d

   Internet Systems Consortium DHCP Server 4.4.1
   Copyright 2004-2018 Internet Systems Consortium.
   All rights reserved.
   For info, please visit https://www.isc.org/software/dhcp/
   ldap_gssapi_principal is not set,GSSAPI Authentication for LDAP will not be used
   Not searching LDAP since ldap-server, ldap-port and ldap-base-dn were not specified in the config file
   Config file: /etc/dhcp/dhcpd.conf
   Database file: /var/lib/dhcp/dhcpd.leases
   PID file: /var/run/dhcp/dhcpd.pid
   Wrote 0 deleted host decls to leases file.
   Wrote 0 new dynamic host decls to leases file.
   Wrote 0 leases to leases file.
   Listening on LPF/eth0/b8:27:eb:36:9b:e9/192.168.1.0/24
   Sending on   LPF/eth0/b8:27:eb:36:9b:e9/192.168.1.0/24
   Sending on   Socket/fallback/fallback-net
   Server starting service.
   DHCPREQUEST for 192.168.1.96 from 4c:d1: ....
```

Output from nmap --script broadcast-dhcp-discover
-------------------------------------------------
```
Starting Nmap 7.40 ( https://nmap.org ) at 2020-01-23 11:01 CET
   Pre-scan script results:
   | broadcast-dhcp-discover:
   |   Response 1 of 1:
   |     IP Offered: 192.168.1.200
   |     DHCP Message Type: DHCPOFFER
   |     Server Identifier: 192.168.1.42
   |     IP Address Lease Time: 5m00s
   |     Subnet Mask: 255.255.255.0
   |     Router: 192.168.1.2
   |     Domain Name Server: 8.8.8.8, 8.8.4.4
   |     Domain Name: gyzzz.eu
   |_    Broadcast Address: 192.168.1.255
   WARNING: No targets were specified, so 0 hosts scanned.
   Nmap done: 0 IP addresses (0 hosts up) scanned in 3.42 seconds
```
