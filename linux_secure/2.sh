#!/bin/bash
#by alvin <zhuyuanwen@hoge.cn>

a=`date +%Y%m%d`
cp 1.defs /m2odata/1.defs-$a

#删除
sed -i '/PASS_MAX_DAYS/'d  1.defs
sed -i '/PASS_MIN_DAYS/'d  1.defs
sed -i '/PASS_MIN_LEN/'d  1.defs
sed -i '/PASS_WARN_AGE/'d 1.defs
#新增
sed -i '20'a'PASS_MAX_DAYS\  \180' 1.defs
sed -i '21'a'PASS_MIN_DAYS\  \0' 1.defs
sed -i '22'a'PASS_MIN_LEN\  \12' 1.defs
sed -i '23'a'PASS_WARN_AGE\  \7' 1.defs
#判断是否成功
if [ $? = 0 ]
then
        echo "Password security is set Successfully!"
else
        "Maybe there are some problems"
fi
