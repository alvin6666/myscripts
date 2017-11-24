#!/bin/bash
# php日志压缩脚本
# 使用方法：根据部署环境来修改 PHP_LOGS, FPM_INIT/FPM_BIN，LOG_PATH, 然后执行 ./cut_phplogs.sh
# 脚本统一存放在 /m2odata/sh 目录，压缩日志存放在LOG_PATH下面的phplogs子目录中

#定义php日志的文件名
PHP_LOG=(php_errors.log php-fpm.log php_slow.log)

#针对PHP 5.3,确保系统环境有php启动脚本，如果没有需手动下载，并放至 /etc/init.d/
FPM_INIT=/etc/init.d/php-fpm

#针对PHP 5.2 版本
FPM_BIN=/usr/local/php/sbin/php

#定义php日志文件存放目录
LOG_PATH=/m2odata/log/
cd $LOG_PATH

#定义日期后缀
DATE_EXT=`date +%Y%m%d`

#定义压缩后日志存放的目录
if [ ! -d phplogs ]; then
	mkdir phplogs
fi

#压缩转储日志
if [ ! -d $DATE_EXT ]; then
	mkdir $DATE_EXT
fi

for i in ${PHP_LOG[@]}; do 
	mv $i $DATE_EXT
done

tar zcPf $DATE_EXT.tar.gz $DATE_EXT --remove-files

#将压缩好的日志，移动至phplogs目录
if [ ! -f phplogs/$DATE_EXT.tar.gz ]; then 
        mv -f $DATE_EXT.tar.gz phplogs
else
        echo '今天的日志已经压缩,如需覆盖请手动操作'
fi

#reload php
$FPM_INIT reload

#针对PHP5.2版本，启用如下命令
#$FPM_BIN reload

#删除10天前的日志
cd phplogs
OldLog=`date -d -10day +%Y%m%d`
rm -f $OldLog.tar.gz

#添加至定时任务
if [ `grep cut_phplogs /var/spool/cron/root|wc -l` -lt 1 ]; then
        if [ ! -f /var/spool/cron/root ]; then
                touch /var/spool/cron/root
        fi  
        echo -ne '1 0 * * * /m2odata/sh/cut_phplogs.sh > /dev/null 2>&1
' >> /var/spool/cron/root
fi

#删除系统logrotate配置
cd /etc/logrotate.d/
if [ -f php ]; then
        rm -f php
fi
echo 'done!'
