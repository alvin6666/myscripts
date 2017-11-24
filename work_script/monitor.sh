#!/bin/bash
# update-time 2016-10-21
# 使用方法: ./monitor.sh

#define variables
APPID=1
APPKEY=z57WNYgO6aI7Nb03Cwf5X1Myco68wMmW
CUSTOM_APPID=213
CUSTOM_APPKEY=nvhl0InuGpTcDgKk5qXJ83c1dzwkibDv
name=`hostname`

#download hogemonitor source code

echo 'download hogemonitor source code'

cd /usr/local/src

if [ -f monitor.tar.gz ]
then
        echo 'already download'
else
        wget "http://op.hoge.cn/package/monitor.tar.gz"
fi

if [ ! -d monitor ]
then
        tar zxvf monitor.tar.gz && mv /usr/local/src/monitor /usr/local/monitor
fi

cd /usr/local/monitor

echo '#!/usr/bin/python' > /usr/local/monitor/config.py
echo '# -*- coding: utf8 -*-' >> /usr/local/monitor/config.py
echo "AUTH_HOST = 'auth_api.app.m2o'" >> /usr/local/monitor/config.py
echo "AUTH_FILE = 'auth/applications.php'" >> /usr/local/monitor/config.py
echo "APPID = $APPID " >> /usr/local/monitor/config.py
echo "APPKEY = '$APPKEY' " >> /usr/local/monitor/config.py
echo "CUSTOM_APPID = $CUSTOM_APPID " >> /usr/local/monitor/config.py
echo "CUSTOM_APPKEY = '$CUSTOM_APPKEY' " >> /usr/local/monitor/config.py
echo "HOST_NAME = '$name' " >> /usr/local/monitor/config.py
`sudo chmod 755 /usr/local/monitor/config.py`
echo "/usr/bin/nohup /usr/local/monitor/hogeMonitor.py -h127.0.0.1 > /dev/null 2>&1 & " >> /etc/rc.local
`/usr/bin/nohup /usr/local/monitor/hogeMonitor.py -h127.0.0.1 > /dev/null 2>&1 &`
monitor_pid=$(ps ax | grep 'hogeMonitor.py' | grep -v 'grep' | awk '{print $1}')
if [ $monitor_pid ];then
        echo "Success:安装python启动成功！"
        else
                echo "Error:安装python启动失败，请检查！"
                exit
        fi
