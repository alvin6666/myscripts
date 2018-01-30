#!/bin/bash
#Date:2017-7-3
#Author:xcn(baishuchao@yeah.net)
#version 1.0
mysql_cmd="mysql -u root -p123456"
errorno=(1158 1159 1008 1007 1062)
while true
do
  array=($($mysql_cmd -e "show slave status\G"|egrep '_Running|Behind_Master|Last_SQL_Errno'|awk '{print $NF}'))
  if [ "${array[0]}" == "Yes" -a "${array[1]}" == "Yes" -a "${array[2]}" == "0" ]
  then
    echo "MySQL is slave is ok"
  else
      for ((i=0;i<${#errorno[*]};i++))
      do
        if [ "${array[3]}" = "${errorno[$i]}" ];then
        $mysql_cmd -e "stop slave &&set global sql_slave_skip_counter=1;start slave;"
        fi
      done
      char="MySQL slave is not ok"
      echo "$char"
      echo "$char"|mail -s "$char" zhuyuanwen@hoge.cn
      break
  fi
  sleep 30
done
