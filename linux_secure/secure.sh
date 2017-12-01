#!/bin/bash
#by alvin <zhuyuanwen@hoge.cn>

###############Password Security###############
#备份文件
a=`date +%Y%m%d`
cp /etc/login.defs /m2odata/login.$a.bak

#替换
sed -i '/^PASS_MAX_DAYS/ s/99999/180/g' 1.defs 
sed -i '/^PASS_MIN_LEN/ s/5/12/g' 1.defs 

#判断是否成功
if [ $? = 0 ]
then
	echo -e "\033[31m Password security is set Successfully! \033[0m"
else
	echo -e "\033[44;37;5m Maybe there are some problems!!! \033[0m"
fi

###############Password Strength###############
#备份文件
cp  /etc/pam.d/system-auth-ac /m2odata/systemd-auth.$a.bak
#删除两行
sed -i '/password    requisite/d' /etc/pam.d/system-auth
sed -i '/password    sufficient/d' /etc/pam.d/system-auth 
#新增两行
sed -i '/password    required/i password    requisite     pam_cracklib.so difok=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1'  /etc/pam.d/system-auth
sed -i '/password    required/i password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok remember=5'  /etc/pam.d/system-auth

#检查是否存在空口令账号
b=`awk -F: '($2 == "") { print $1 }' /etc/shadow`
if [ $b="" ]
then
	echo "It's Good!"
else
	echo -e "\033[44;37;5m It's unsafety!!! \033[0m"
fi

###############Account Security###############
for i in {lp,sync,shutdown,halt,news,uucp,operator,games,gopher}
do
        m=`sed -n  "/$i/p" /data/alvin/myscripts/linux_secure/2.txt|awk -F ":" {'print $2'}`

if [ $m !== * ]
then
        print $i
else
	echo "related user is lock"
fi

done
