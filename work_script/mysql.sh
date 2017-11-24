#!/bin/bash
# 使用方式: ./mysql.sh

# download mysql source code
echo 'download mysql source code'
cd /usr/local/src
if [ -f mysql-5.5.43-linux2.6-x86_64.tar.gz ]; then
	echo 'already download'
else
	wget "http://218.2.102.114:57624/src/mysql-5.5.43-linux2.6-x86_64.tar.gz"
fi
echo -e 'done\n'

# create user mysql and directories
echo 'create mysql user'
if [ `grep -q mysql /etc/passwd` ]; then
	echo 'user mysql already exists';
else
	useradd -M -s /sbin/nologin mysql
fi

# install mysql-5.5.43
echo 'install mysq-5.5.43'
tar xzvf mysql-5.5.43-linux2.6-x86_64.tar.gz
mv -f mysql-5.5.43-linux2.6-x86_64 /m2odata/server/
ln -sf /m2odata/server/mysql-5.5.43-linux2.6-x86_64 /m2odata/server/mysql

chown -R mysql:mysql /m2odata/server/mysql/
if [ ! -d /m2odata/data/mysql ]; then
	mkdir -p /m2odata/data/mysql
fi
\cp -rf /m2odata/server/mysql/data/* /m2odata/data/mysql/
chown -R mysql:mysql /m2odata/data/mysql

echo -e 'done\n'

# configure my.cnf
echo 'configure my.cnf'
wget "http://218.2.102.114:57624/configfiles/my.cnf" -O /etc/my.cnf
echo -e 'done\n'

# install necessary packages
echo 'install necessary packages'
yum -y install compat-libstdc++-33.x86_64 libaio.x86_64
echo -e 'done\n'

# start mysql
echo 'initialize'
cd /m2odata/server/mysql
./scripts/mysql_install_db --user=mysql
\cp -f ./support-files/mysql.server /etc/rc.d/init.d/mysqld
chown root:root /etc/rc.d/init.d/mysqld
chmod 755 /etc/rc.d/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
service mysqld start
echo -e 'done\n'

# initialize
echo 'initialize'
/m2odata/server/mysql/bin/mysql_secure_installation
echo -e 'done\n'
