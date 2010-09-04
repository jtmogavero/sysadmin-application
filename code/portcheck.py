#!/usr/bin/python
#Python script to be used for checking the state of a TCP port
#This was written to be invoked by a shell script, portcheck.sh but works stand-alone
#Since it was written for my own use, there is very little error checking


import socket
import sys

if ( len(sys.argv) != 3 ):
    print "Usage: " + sys.argv[0] + " enter the IPv4 address or FQDN and port number"
    print "Example:  portcheck.py www.google.com 80"
    sys.exit(1)

remote_host = sys.argv[1]
remote_port = int(sys.argv[2])

while True:
        print "Checking to see if port " + str(remote_port) + " is open on host " + remote_host
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        try:
                sock.connect((remote_host, remote_port))
        except Exception, e:
                print "Port " + str(remote_port) + " is closed.  Boo!"
                #print sys.exc_info()[0]
                break
        else:
                print "Port " + str(remote_port) + " is open.  Hooray!"
                break
sock.close()
