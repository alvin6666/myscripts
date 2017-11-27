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

sed -i '/password/'d  2.auth

sed -i '14'a'password\   \ requisite\     \pam_cracklib.so\ \difok=3\ \minlen=12\ \ucredit=-1\ \lcredit=-1\ \dcredit=-1' 2.auth  
sed -i '15'a'password\    \sufficient\    \pam_unix.so\ \md5\ \ shadow\ \nullok\ \try_first_pass\ \use_authtok\ \remember=5' 2.auth
sed -i '16'a'password\     \required\      \pam_deny.so' 2.auth

awk -F: '($2 == "") { print $1 }' /etc/shadow
