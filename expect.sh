#!/bin/bash
/usr/bin/expect -c ”
#设置10s等待时间
set timeout 10
spawn ssh root@10.0.5.195
expect “password:” {exp_send “root123″\r;}
interact”
