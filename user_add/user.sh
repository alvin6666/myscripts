#!/bin/bash

user=`cat user.txt`

for i in $user

do

userdel -r  $i

echo "123456" | passwd --stdin $i  
done
