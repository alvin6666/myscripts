#!/bin/bash

#定义变量安装目录
install_dir=/usr/local/src/xunsearch-full-1.4.9/

#获取IP
IP=`ifconfig $1|sed -n 2p|awk  '{ print $2 }'|awk -F : '{ print $2 }'`

cd /usr/local/src

if [ -f xunsearch.tar.bz2  ]

then
        echo -e "\033[31m 迅搜已下载！\033[0m "

else
        wget http://218.2.102.114:57624/src/xunsearch.tar.bz2
fi


if [ -d xunsearch-full-1.4.9 ]
then
        echo -e "\033[31m 迅搜已解压！\033[0m " 
else
        tar jxvf xunsearch.tar.bz2

fi

cd $install_dir

#自动完成交互,回车,输入yes
sh setup.sh <<EOF

Y
EOF

#防火墙开通8383,8384端口
sed -i '/80/a-A INPUT -m state --state NEW -m tcp -p tcp --dport 8384 -j ACCEPT' /etc/sysconfig/iptables
sed -i '/80/a-A INPUT -m state --state NEW -m tcp -p tcp --dport 8383 -j ACCEPT' /etc/sysconfig/iptables

service iptables restart

#加入开机自启动
echo -ne "/usr/local/xunsearch/bin/xs-ctl.sh -b$IP start" >> /etc/rc.local

#启动服务
/usr/local/xunsearch/bin/xs-ctl.sh -b$IP start



