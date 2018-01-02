#!/bin/bash
#图片本地化

#安装yum源
yum -y install epel-release
#安装相关包
yum -y install libwebp-devel libpng-devel libjpeg-devel

#安装imagemagick基于Centos6.8最新版
cd /usr/local/src
if [ -f ImageMagick-6.9.8-6.tar.gz ]
then 
	echo "already download"
else
	wget "http://218.2.102.114:57624/src/ImageMagick-6.9.8-6.tar.gz"
	#wget "http://www.imagemagick.org/download/ImageMagick-6.9.8-8.tar.gz"
fi

if [ ! -d ImageMagick-6.9.8-6 ];then
	tar zxvf ImageMagick-6.9.8-6.tar.gz
fi

if [ ! -f /usr/local/bin/convert ]; then
	cd ImageMagick-6.9.8-6
	./configure
	make && make install
else	
	echo "ImageMagick already installed!"
fi

#判断ImageMagick安装成功后是否支持WEBP格式
form=`convert -list format|grep webp|wc -l`
if [ $form=1 ]
then
	echo "已支持WEBP格式!" && wget "http://www.magickwand.org/download/php/MagickWandForPHP-1.0.9-2.tar.gz" -O /usr/local/src/MagickWandForPHP-1.0.9-2.tar.gz
else
	echo "Failed install Imageick" && exit
fi
	tar zxvf MagickWandForPHP-1.0.9-2.tar.gz
	cd MagickWandForPHP-1.0.9
	/m2odata/server/php/bin/phpize
	./configure --with-php-config=/m2odata/server/php/bin/php-config
	make && make install

if [ $? = 0 ]
then
	echo "Magickwand install successfully!"
else
	echo "Failed install Magickwand" && exit
fi

#定义变量
magic=`cat /m2odata/server/php/etc/php.ini|grep magickwand|wc -l`

#在php.ini配置文件中加上动态库文件配置
if [ $magic=0 ]
then
	sed -i '/extension = "imagick.so"/aextension = "magickwand.so"' /m2odata/server/php/etc/php.ini
	sed -i '/extension = "imagick.so"/s/^;//' /m2odata/server/php/etc/php.ini
else
	echo "配置文件中已有magickwand库文件!" && exit
fi
