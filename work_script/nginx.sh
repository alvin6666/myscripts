#!/bin/bash
# update-time 2015-08-06
# 更新内容: 
# 1. cdn 服务添加 ngx_cache_purge 模块, 其他服务器安装http_img_filter_module模块
# update-time 2015-12-04
# 更新内容：
# 1. 更新nginx默认配置文件
# 2. 取消他服务器安装http_img_filter_module模块
# 使用方法: ./nginx.sh

# download nginx stable source code
echo 'download nginx source code'
cd /usr/local/src 

if [ -f nginx-1.8.0.tar.gz ]; then
	echo 'already download'
else
	wget "http://218.2.102.114:57624/src/nginx-1.8.0.tar.gz"
fi

tar zxf nginx-1.8.0.tar.gz
cd nginx-1.8.0
echo -e 'done\n'

# install nginx
echo 'install nginx'
sed -i '/CFLAGS/s/^CFLAGS/#CFLAGS/' auto/cc/gcc
if [[ `hostname` == live* ]]; then
./configure --user=www --group=www --prefix=/m2odata/server/nginx-1.8.0 --with-http_stub_status_module --with-http_sub_module --with-http_mp4_module

elif [[ `hostname` == *cdn* ]]; then
cd /usr/local/src && echo 'add ngx_cache_purge module'

if [ ! -f ngx_cache_purge-2.3.tar.gz ]; then
        wget "http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz"
fi

if [ ! -d ngx_cache_purge-2.3 ]; then
	tar zxvf ngx_cache_purge-2.3.tar.gz
fi

cd /usr/local/src/nginx-1.8.0
./configure --user=www --group=www --prefix=/m2odata/server/nginx-1.8.0 --with-http_stub_status_module --with-http_sub_module --add-module=/usr/local/src/ngx_cache_purge-2.3

else
./configure --user=www --group=www --prefix=/m2odata/server/nginx-1.8.0 --with-http_stub_status_module --with-http_sub_module
fi
make -j4 && make install
ln -sf /m2odata/server/nginx-1.8.0 /m2odata/server/nginx
ln -sf /m2odata/server/nginx/sbin/nginx /sbin/nginx
echo -e 'done\n'

# add to rc.local
echo 'add to rc.local'
if [ `grep nginx /etc/rc.local|wc -l` -lt 1 ]; then
echo -ne "/m2odata/server/nginx/sbin/nginx -c /m2odata/server/nginx/conf/nginx.conf

" >> /etc/rc.local
fi
echo -e 'done\n'

# configure nginx
echo 'configure nginx'
cd /m2odata/server/nginx/conf/
wget -O nginx.conf "http://218.2.102.114:57624/configfiles/nginx.conf"
wget -O fastcgi_params "http://218.2.102.114:57624/configfiles/fastcgi_params"
echo 'done!'

if [ ! -d conf.d/ ]; then
	mkdir conf.d 
fi

if [ ! -f /m2odata/server/nginx/logs/nginx.pid ]; then
	echo 'start nginx'
	/m2odata/server/nginx/sbin/nginx
else
	echo 'restart nginx'
	/m2odata/server/nginx/sbin/nginx -s stop
	[ ! -f /m2odata/server/nginx/logs/nginx.pid ] || /m2odata/server/nginx/sbin/nginx
fi
