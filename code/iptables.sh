#!/bin/sh

# This is to be installed/run on each of the two Avamar nodes on
# the customer network.  

# In the case that something goes terribly wrong invoke the command:
# "service iptables stop".  To see if the parameters are loaded run
# "iptables -L"

# Path to the iptables command
IPT="/sbin/iptables"

# Flush old rules, old custom tables
$IPT --flush
$IPT --delete-chain

# Set default policies for all three default chains, drop all incoming and 
# forwarded packets, allow outgoing packets
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# Enable free use of loopback interfaces
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Allow returning packets
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow full communication between both nodes and admin IPs

$IPT -A INPUT -s 138.26.107.99 -j ACCEPT
$IPT -A INPUT -s 138.26.107.100 -j ACCEPT
$IPT -A INPUT -s 138.26.118.116 -j ACCEPT
$IPT -A INPUT -s 138.26.107.63 -j ACCEPT
$IPT -A INPUT -s 138.26.105.216 -j ACCEPT



# Allow DNS and NTP access from the appropriate servers


$IPT -A INPUT -p udp -m udp --dport 53 -s 138.26.105.1 -j ACCEPT
$IPT -A INPUT -p tcp -m tcp --dport 53 -s 138.26.105.2 -j ACCEPT
$IPT -A INPUT -p udp -m udp --dport 123 -s 138.26.134.200 -j ACCEPT
$IPT -A INPUT -p tcp -m tcp --dport 123 -s 138.26.134.249 -j ACCEPT



# The follow is a list of all client IP addresses that should have access to
# the nodes for backup

client_ips=(   #WWW.XXX.YYY.ZZZ
	138.26.105.1
	138.26.105.2
	138.26.105.3
	138.26.105.15
	138.26.105.17
	138.26.105.19
	138.26.105.37
	138.26.105.39
	138.26.105.44
	138.26.105.68
	138.26.105.71
	138.26.105.72
	138.26.105.73
	138.26.105.83
	138.26.105.92
	138.26.105.98
	138.26.105.118
	138.26.105.149
	138.26.105.191
	138.26.105.193
	138.26.105.200
	138.26.105.219
	138.26.105.218
	138.26.105.220
	138.26.107.10
	138.26.118.40
	138.26.118.57
	138.26.118.59
	138.26.118.152
	138.26.118.170
     )


for host in ${client_ips[@]}

do
   # Allow clients to register with the MCS and back up via SSL
   $IPT -A INPUT -p tcp -m tcp --dport 28001 -s $host -j ACCEPT
   $IPT -A INPUT -p tcp -m tcp --dport 29000 -s $host -j ACCEPT
   $IPT -A INPUT -p icmp -m icmp -s $host -j ACCEPT
	
done

#  DROP all other traffic and log it

$IPT -A INPUT -p tcp -m tcp -m limit --limit 1/second --limit-burst 10 -j LOG --log-level 7 --log-prefix "Dropped TCP: "
$IPT -A INPUT -p tcp -m tcp  -j DROP
$IPT -A INPUT -p tcp -m tcp -m limit --limit 1/second --limit-burst 10 -j LOG --log-level 7 --log-prefix "Dropped UDP: "
$IPT -A INPUT -p udp -m udp  -j DROP