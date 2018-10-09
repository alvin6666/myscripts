#!/bin/bash

while read line;do
        ip=`echo $line | cut -d " " -f1`             # 提取文件中的ip
        user=`echo $line | cut -d " " -f2`      # 提取文件中的用户名
        port=`echo $line | cut -d " " -f3`

output1=`ssh -p $port $user@$ip "sed -n '/10.160.250.8/p' /python/2018/11.txt"`
output2=`ssh -p $port $user@$ip "sed -n '/10.160.251.8/p' /python/2018/11.txt"`


if [ -n "$output1" ]
then
        echo "DNS1 已经添加！"
else
	ssh -p $port $user@$ip "echo -e 'DNS1=10.160.250.8'>> /python/2018/11.txt"
fi

if [ -n "$output2" ]
then
        echo "DNS2 已经添加！"
else
	ssh -p $port $user@$ip "echo -e 'DNS2=10.160.251.8'>> /python/2018/11.txt"
fi

ssh -p $port $user@$ip "systemctl restart network.service"

done < /python/2018/ip.txt
