#!/bin/bash
#by alvin <zhuyuanwen@hoge.cn>

###############Password Security###############
a=`date +%Y%m%d`
cp /etc/login.defs /m2odata/a.bak

#删除
sed -i '/PASS_MAX_DAYS/'d  /etc/login.defs
sed -i '/PASS_MIN_DAYS/'d  /etc/login.defs
sed -i '/PASS_MIN_LEN/'d  /etc/login.defs
sed -i '/PASS_WARN_AGE/'d /etc/login.defs
#新增
sed -i '20'a'PASS_MAX_DAYS\  \180' /etc/login.defs
sed -i '21'a'PASS_MIN_DAYS\  \0' /etc/login.defs
sed -i '22'a'PASS_MIN_LEN\  \12' /etc/login.defs
sed -i '23'a'PASS_WARN_AGE\  \7' /etc/login.defs
#判断是否成功
if [ $? = 0 ]
then
	echo "Password security is set Successfully!"
else
	"Maybe there are some problems"
fi

###############Password Strength###############


awk -F: '($2 == "") { print $1 }' /etc/shadow
