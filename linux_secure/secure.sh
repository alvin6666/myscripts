#!/bin/bash
#by alvin <zhuyuanwen@hoge.cn>

###############Password Security###############
#备份文件
a=`date +%Y%m%d`
cp /etc/login.defs /m2odata/bak/login.$a.bak

#替换
sed -i '/^PASS_MAX_DAYS/ s/99999/180/g' 1.defs 
sed -i '/^PASS_MIN_LEN/ s/5/12/g' 1.defs 

#判断是否成功
if [ $? = 0 ]
then
	echo -e "\033[32m Password security is set Successfully! \033[0m"
else
	echo -e "\033[41;37;5m Maybe there are some problems!!! \033[0m"
fi

###############Password Strength###############
#备份文件
cp  /etc/pam.d/system-auth-ac /m2odata/bak/systemd-auth.$a.bak
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
	echo -e "\033[32m It's Good! \033[0m"
else
	echo -e "\033[41;37;5m It's unsafety!!! \033[0m"
fi

###############Account Security###############
for i in {lp,sync,shutdown,halt,news,uucp,operator,games,gopher}
do
        m=`sed -n  "/$i/p" /etc/shadow|awk -F ":" {'print $2'}`
if [[ "$m" = "*"  ]]
then
	echo -e "\033[32m These system accounts have been locked up! \033[0m"
elif [[ "$m" = ""  ]]
then
	echo -e "\033[32m The system account does not exist! \033[0m"
else
	echo -e "\033[41;37;5m The system account is unlocked AND It's UNSAFETY!!! \033[0m"
fi
done

###############User locking policy###############
n=`sed -n '/pam_tally2/p' /etc/pam.d/system-auth`
if [[ "$n" = ""  ]]
then
        sed -i '/auth        required      pam_deny.so/a auth        required      pam_tally2.so deny=10 unlock_time=300 even_deny_root root_unlock_time=300' /etc/pam.d/system-auth/g && echo -e "\033[32m User locking policy has just been set! \033[0m"
else
        echo -e "\033[32m User lock policy has been set up! \033[0m"
fi
###############tty terminal limitation###############
cp /etc/securetty  /m2odata/bak/securetty_$a
for i in `seq 1 20`
do
if [ $i -ne 1 ]
then
        sed -i "/tty$i/d" /etc/securetty
else
        echo -e "\033[32m Other tty has been deleted! \033[0m"
fi
done
###############Root user remote login restriction###############
c=`sed -n "/#PermitRootLogin yes/p" /etc/ssh/sshd_config`
if [[ $c != "" ]]
then
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config && service sshd reload
else
	echo -e "\033[31mUser root can't be remote directly!!! \033[0m"
fi
