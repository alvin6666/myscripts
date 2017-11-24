#!/bin/bash
#安装redis

Down_DIR=/usr/local/src

yum -y install gcc jemalloc-devel

cd $Down_DIR  && wget -c http://download.redis.io/releases/redis-3.2.0.tar.gz && tar xzf redis-3.2.0.tar.gz

cd redis-3.2.0 && make

if [ $? -eq 0 ]
then
        make PREFIX=/usr/local/redis  install

        if [ $? -eq 0 ]
        then
                mkdir /usr/local/redis/etc/ && mkdir /usr/local/redis/var/ && chmod 777 /usr/local/redis/var/ && wget http://www.apelearn.com/study_v2/.redis_conf -O /usr/local/redis/etc/redis.conf
		/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
                echo  -e "\033[32mThe Redis Install Successfully!!!\033[0m"

        else
        echo  -e "\033[32mNeed to be checked!!!\033[0m"
        fi
else
        echo  -e "\033[32mFailed!!!\033[0m"
fi
