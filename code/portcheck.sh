#!/bin/bash
# This shell script prints the current date/time, send 4 ICMP packets 
# to the specified host, and calls upon portcheck.py to check
# port status.  This should be invoked in the shell by running it with 
# nohup and redirecting the output to a text file.  
# Example:  nohup portcheck.sh 2>&1 > portcheck.log &


X=0
while [ $X = 0 ]
do
echo `date +%b" "%d" "%r`
echo `ping -c 4 forums.somethingawful.com`
echo `./portcheck.py forums.somethingawful.com 80`
sleep 300
done
