#!/bin/bash
#by alvin <zhuyuanwen@hoge.cn>

###############Password Security###############
###############口令安全设置###############
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
###############口令强度设置###############
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
###############账户安全设置###############
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
###############用户锁定策略###############
n=`sed -n '/pam_tally2/p' /etc/pam.d/system-auth`
if [[ "$n" = ""  ]]
then
        sed -i '/auth        required      pam_deny.so/a auth        required      pam_tally2.so deny=10 unlock_time=300 even_deny_root root_unlock_time=300' /etc/pam.d/system-auth/g && echo -e "\033[32m User locking policy has just been set! \033[0m"
else
        echo -e "\033[32m User lock policy has been set up! \033[0m"
fi
###############tty terminal limitation###############
###############tty终端限制###############
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
###############root用户远程登陆限制###############
c=`sed -n "/#PermitRootLogin yes/p" /etc/ssh/sshd_config`
if [[ $c != "" ]]
then
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config && service sshd reload
else
	echo -e "\033[31mUser root can't be remote directly!!! \033[0m"
fi

cc=`sed -n "/Protocol/p" /etc/ssh/sshd_config`

if [[ "$cc" = "Protocol 2" ]]
then
        echo -e "\033[32mSSH Protocol version has been 2!!! \033[0m"
else
        sed -i "s/$cc/Protocol 2/g" /etc/ssh/sshd_config && service sshd reload
fi
###############new user for remote landing############### 
###############新建普通用户用于远程登陆###############
cp /etc/passwd /m2odata/bak/passwd.$a
yum -y install epect  > /dev/null 2>&1
if [ -f /m2odata/bak/user.txt ]
then
        echo -e "\033[31mThe file exists!!! \033[0m"
else
        touch /m2odata/bak/user.txt
fi

d=`sed -n '/hogesoft/p' /etc/passwd`

if      [[ $d != "" ]]
then
        echo -e "\033[31mThe user exists!!! \033[0m"
else
        f=`mkpasswd -l 12 -d 2 -C 2 -s -1`
        useradd hogesoft && echo hogesoft:$f|chpasswd && echo $f > /m2odata/bak/user.txt
fi
###############Check whether there is a user with UID 0 except root###############
###############检查是否存在除root之外UID为0的用户###############
e=`awk -F: '($3 == 0) { print $1 }' /etc/passwd |grep '[^root]'`
if [[ $e != "" ]]
then
        echo -e "\033[41;37;5m There are users with UID 0 apart from root!!! \033[0m" && exit
else
        echo -e "\033[32mIt's ok!!! \033[0m"
fi
###############root用户环境变量的安全性###############
#检查是否包含父目录
g=`echo $PATH | egrep '(^|:)(\.|:|$)'`
if [[ $g != "" ]]
then
        echo -e "\033[41;37;5m 包含父目录!!! \033[0m"
else
        echo -e "\033[32m不包含父目录,It's OK!!! \033[0m"
fi


#检查是否包含组目录权限为777的目录
find `echo $PATH | tr ':' ' '` -type d \( -perm -002 -o -perm -020 \) -ls > 1.txt 2>&1
find `echo $PATH | tr ':' ' '` -type d \( -perm -002 -o -perm -020 \) -ls > 2.txt

j=`cat 1.txt`
k=`cat 2.txt`

if [[ $j = "" ]]
then
        echo -e "\033[41;37;5m包含主目录,Unsafety!!! \033[0m"
elif [[ $k = "" ]]
then
        echo -e "\033[32mNo file permissions exceed 777!!! \033[0m"
else
        echo -e "\033[41;37;5mA file permissions exceed 777 Unsafety!!! \033[0m"
fi
###############查找未授权的SUID/SGID文件###############
for PART in `grep -v ^# /etc/fstab | awk '($6 != "0") {print $2}'`
do
find $PART \( -perm -04000 -o -perm -02000 \) -type f -xdev  -print  > 3.txt &
done

l=`grep -v -E "^/sbin|^/usr|^/bin|^/lib64" 3.txt`
if [[ $l = "" ]]
then
        echo -e "\033[32mNo problem!!! \033[0m"
else
        echo -e "\033[41;37;5mThere are other unauthorized files in the system Unsafety!!! \033[0m"
fi
###############检查任何人都有写权限的目录###############
for PASS in `awk '($3 == "ext4" || $3 == "ext3" ) {print $2}' /etc/fstab`
do
find $PASS -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print  > /m2odata/bak/m.txt &
done
sleep 1
m=`cat /m2odata/bak/m.txt`

if [[ $m != "" ]]
then
        echo -e "\033[41;37;5mThere are catalogues that anyone can write. Please check the file m.txt!!! \033[0m"
else
        echo -e "\033[32mGood!!! \033[0m" 
fi
###############检查任何人都有写权限的文件###############
for PASS in `awk '($3 == "ext4" || $3 == "ext3" ) {print $2}' /etc/fstab`
do
find $PASS -xdev -type f \( -perm -0002 -a ! -perm -1000 \) -print > /m2odata/bak/n.txt &
done
sleep 1
n=`cat /m2odata/bak/n.txt`

if [[ $n != "" ]]
then
        echo -e "\033[41;37;5mA file permissions can be written by anyone. Please check the file n.txt!!! \033[0m"
else
        echo -e "\033[32mGood!!! \033[0m" 
fi
###############Banner信息###############
echo “非授权用户禁止登录，所有行为均有审计监控”>/etc/issue
echo “非授权用户禁止登录，所有行为均有审计监控”>/etc/issue.net
echo “非授权用户禁止登录，所有行为均有审计监控”>/etc/motd

###############登陆超时设置###############
cp /etc/profile /m2odata/bak/profile.$a
o=`sed -n "/TMOUT/p" /etc/profile`
if [[ $o = "" ]]
then
        sed -i '$aTMOUT=600' /etc/profile && source /etc/profile
else
        echo -e "\033[32mTMOUT已经被设置为600!!! \033[0m"
fi
###############远程连接的安全性设置###############
p=`find  / -name  .netrc`
q=`find  / -name  .rhosts`

if [[ "$p" = "" ]]
then
        echo -e "\033[32mNo .netrc file!!! \033[0m" 
else
        echo -e "\033[41;37;5mPlease check the system file!!! \033[0m"
fi

if [[ "$q" = "" ]]
then
        echo -e "\033[32mNo .rhosts file!!! \033[0m" 
else
        echo -e "\033[41;37;5mPlease check the system file again!!! \033[0m"
fi
###############内核参数配置###############
if [ `grep redirects /etc/sysctl.conf|wc -l` -lt 1 ]; then
echo -ne 'net.ipv4.conf.default.send_redirects=0 
net.ipv4.conf.default.accept_redirects=0
net.ipv4.icmp_echo_ignore_broadcasts=1
' >>/etc/sysctl.conf
else
        echo -e "\033[32mHave been configured well!!! \033[0m" 
fi
