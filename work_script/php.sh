#!/bin/bash
# update time: 2015-06-09 23:00
# 使用方法: 根据机器实际性能,修改MAX_CHILDREN参数为合适值,然后执行 ./php.sh

# set max_children
MAX_CHILDREN=100		# max_children in php-fpm.conf

# download php source code
echo 'download php source code'
cd /usr/local/src 

if [ -f php5.3.29_p1-bin.tar.gz ]; then
	echo 'already download'
else
	wget "http://218.2.102.114:57624/src/php5.3.29_p1-bin.tar.gz"
fi

tar zxf php5.3.29_p1-bin.tar.gz
echo -e 'done\n'

# install php5.3.29_p1
echo 'install php5.3.29_p1'
cd php5.3.29-bin
\cp -rf php-5.3.29 /m2odata/server/
ln -sf /m2odata/server/php-5.3.29 /m2odata/server/php

\cp -f php-fpm /etc/init.d/

chown root:root /etc/rc.d/init.d/php-fpm
chmod 755 /etc/rc.d/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on

mkdir -p /usr/local/mysqllib_php/lib/
\cp -f libmysqlclient.so.18.0.0 /usr/local/mysqllib_php/lib/
ln -sf /usr/local/mysqllib_php/lib/libmysqlclient.so.18.0.0 /usr/lib64/libmysqlclient.so.18
chmod 755 /usr/local/mysqllib_php/lib/libmysqlclient.so.18.0.0

mkdir -p /usr/local/lib/
\cp -f libmcrypt.so.4.4.8 /usr/local/lib/
ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4
chmod 755 /usr/local/lib/libmcrypt.so.4.4.8

\cp -f libiconv.so.2.5.1 /usr/local/lib/
ln -sf /usr/local/lib/libiconv.so.2.5.1 /usr/lib64/libiconv.so.2
chmod 755 /usr/local/lib/libiconv.so.2.5.1

# configure php
echo 'configure php'
sed -i "/^display_errors/s/On/Off/"	/m2odata/server/php/etc/php.ini
if [ $MAX_CHILDREN != '' ];then
	sed -i "/max_children/s/256/$MAX_CHILDREN/"	/m2odata/server/php/etc/php-fpm.conf
fi
sed -i '/max_input_vars/s/1000/3000/' /m2odata/server/php/etc/php.ini
echo -e 'done\n'

# configure xcache
echo 'configure xcache'
cd /usr/local/src/

if [ ! -f xcache-3.1.2.tar.gz ]; then
	wget "http://218.2.102.114:57624/src/xcache-3.1.2.tar.gz"
fi

tar zxvf xcache-3.1.2.tar.gz

if [ ! -d /m2odata/www/xcache ]; then
	mv xcache-3.1.2/htdocs /m2odata/www/xcache
fi

if [ -h /m2odata/server/nginx ]; then
echo -ne 'server {
        set $htdocs /m2odata/www/xcache;
        listen       80;
        server_name  xcache.app.m2o;
        location / {
        	root   $htdocs;
        	index  index.html index.htm index.php;
        }
        location ~ .*\.php?$ {
        	root          $htdocs;
        	fastcgi_pass unix:/dev/shm/php-cgi.sock;
        	fastcgi_index  index.php;
        	include        fastcgi_params;
        }
}' > /m2odata/server/nginx/conf/conf.d/xcache.conf
fi
echo -e 'done\n'

# start php
echo 'start php-fpm'
if [ ! -S /dev/shm/php-cgi.sock ]; then
	service php-fpm start
fi
echo -e 'done\n'
