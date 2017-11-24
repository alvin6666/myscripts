#!/bin/bash
hist=`cat ping.txt`

for ip in $hist

do
 ping -c 3 -i 0.2 -W 3 $ip &> /dev/null 	
if [ $? -eq 0 ]

then
	echo "host $ip is up"

else
	echo "host $ip is down"
fi
done
