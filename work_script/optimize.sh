#!/bin/bash
# update-time: 2015-11-12
# 更新内容:
# 1. 创建 /m2odata 目录时,会排查掉 nfs 分区
# 2. 去除 /etc/rc.local 中的高并发配置参数
# 3. /etc/hosts.allow 添加公司IP
# 4. 去除 denyhosts 服务安装步骤 
# 使用方法:
# 确保服务器能上网,然后修改HOST_NAME为需要设置的主机名,再执行 ./optimize.sh
 

# set hostname
HOST_NAME=m2o				# 服务器主机名

# set hostname
echo 'set hostname'
if [ $HOSTNAME != '' ];then
        sed -i "/HOSTNAME/s/localhost.localdomain/$HOST_NAME/" /etc/sysconfig/network
        hostname $HOST_NAME
fi
echo -e 'done'

# set selinux to disabled
echo 'set selinux to disabled'
sed -i '/SELINUX/s/enforcing/disabled/' /etc/sysconfig/selinux
setenforce 0
echo -e 'done\n'

# configure sysctl.conf
echo 'configure sysctl.conf'
cd /etc/
rm -f sysctl.conf
wget "http://218.2.102.114:57624/configfiles/sysctl.conf"
sysctl -p
echo -e 'done\n'

# stop ip6tables
chkconfig ip6tables off
if [ -f /var/lock/subsys/ip6tables ]; then
	service ip6tables stop
fi

# configure file handlers
echo 'configure file handlers'
sed -i /soft/s/^*/#*/   /etc/security/limits.d/90-nproc.conf 
if [ `grep 65536 /etc/security/limits.conf|wc -l` -lt 1 ]; then
echo -ne '* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
' >>/etc/security/limits.conf
fi
echo -e 'done\n'

# set time synchronization
echo 'set time synchronization'
if [ `grep ntpdate /var/spool/cron/root|wc -l` -lt 1 ]; then
	if [ ! -f /var/spool/cron/root ]; then
		touch /var/spool/cron/root
	fi
	echo -ne '1 * * * * /usr/sbin/ntpdate time7.aliyun.com > /dev/null 2>&1
' >> /var/spool/cron/root
fi
echo -e 'done\n'

# install necessary packages
echo 'install necessary packages'
yum -y update 
yum -y install unzip lrzsz telnet dos2unix wget pcre-devel ntp vim-enhanced gcc gcc-c++ gcc-gfortran flex bison autoconf automake make bzip2 bzip2-devel.x86_64 ncurses ncurses-devel.x86_64 libjpeg-turbo.x86_64 libjpeg-turbo-devel.x86_64 libpng.x86_64 libpng-devel libtiff.x86_64 libtiff-devel freetype.x86_64 freetype-devel pam-devel.x86_64 curl.x86_64 curl-devel.x86_64 libcurl-devel.x86_64 zlib zlib-devel.x86_64 glibc glibc-devel.x86_64 glib2.x86_64 glib2-devel.x86_64 gettext-devel.x86_64 libtool libxml2.x86_64 libxml2-devel.x86_64 e2fsprogs e2fsprogs-devel.x86_64 krb5-devel.x86_64 libidn.x86_64 libidn-devel.x86_64 openssl openssl-devel.x86_64 libtidy-devel gd-devel.x86_64
echo -e 'done\n'

# install other packages
echo 'install other packages'
yum -y install dstat nmon sysstat tcpdump strace openssh-clients python-devel python-pip
echo -e 'done\n'

# create user and directories
echo 'create m2o directories'
if [ -d /m2odata -o -h /m2odata ]; then
	echo '/m2odata already exists';
else
	dir=`df -mP|egrep -v 'tmpfs|Used|:'|awk '{print $2,$6;}'|sort -nr|head -1|cut -d ' ' -f 2`
	if [ $dir = '/' ]; then
		mkdir /m2odata
	else
		mkdir $dir/m2odata
		ln -s $dir/m2odata /m2odata
	fi
fi

echo 'create www user'
if  grep -q ^www /etc/passwd ; then
	echo 'user www already exists';
else
	useradd -M -s /sbin/nologin www
fi

if [ ! -d /m2odata/server ]; then
mkdir -p /m2odata/server
fi

if [ ! -d /m2odata/log ]; then
mkdir -p /m2odata/log
fi

if [ ! -d /m2odata/tmp ]; then
mkdir -p /m2odata/tmp
fi

if [ ! -d /m2odata/www ]; then
mkdir -p /m2odata/www
fi

if [ ! -d /m2odata/sh ]; then
mkdir -p /m2odata/sh
fi

cd /m2odata
chmod 777 log
chmod 777 tmp
chown -R www:www log
chown -R www:www www
echo -e 'done\n'
