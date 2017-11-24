#!/bin/bash
# nginx日志压缩脚本
# 使用方法: 根据部署环境来修改 NGINX_LOGS, NGINX_BIN，LOG_PATH, 然后执行 ./cut_nginxlogs.sh
# 脚本统一存放在 /m2odata/sh 目录，压缩日志存放在LOG_PATH下面的nginxlogs子目录中

#定义nginx日志的文件名
NGINX_LOG=(m2o_access.log m2o_error.log)

#定义nginx执行文件名
NGINX_BIN=/m2odata/server/nginx/sbin/nginx

#定义nginx日志文件存放目录
LOG_PATH=/m2odata/log/
cd $LOG_PATH

#定义日期后缀
DATE_EXT=`date +%Y%m%d`

#定义压缩后日志存放的目录
if [ ! -d nginxlogs ]; then
	mkdir nginxlogs
fi

#压缩转储日志
if [ ! -d $DATE_EXT ]; then
	mkdir $DATE_EXT
fi

for i in ${NGINX_LOG[@]}; do 
	mv $i $DATE_EXT
done

tar zcPf $DATE_EXT.tar.gz $DATE_EXT --remove-files

#将压缩好的日志，移动至nginxlogs目录
if [ ! -f nginxlogs/$DATE_EXT.tar.gz ]; then 
	mv -f $DATE_EXT.tar.gz nginxlogs
else
	echo '今天的日志已经压缩,如需覆盖请手动操作'
fi	

#reload nginx
$NGINX_BIN -s reload

#删除10天前的日志
cd nginxlogs
OldLog=`date -d -10day +%Y%m%d`
rm -f $OldLog.tar.gz

#添加至定时任务
if [ `grep cut_nginxlogs /var/spool/cron/root|wc -l` -lt 1 ]; then
        if [ ! -f /var/spool/cron/root ]; then
                touch /var/spool/cron/root
        fi  
        echo -ne '1 0 * * * /m2odata/sh/cut_nginxlogs.sh > /dev/null 2>&1
' >> /var/spool/cron/root
fi

#删除系统logrotate配置
cd /etc/logrotate.d/
if [ -f nginx ]; then
        rm -f nginx
fi
echo 'done!'
