#!/bin/bash
echo
cd /usr/local
echo
wget https://wuyi-1251424646.cos.ap-beijing-1.myqcloud.com/ygk/ygk.zip && unzip ygk.zip
echo
rm -f ./ygk.zip
echo
bash /usr/local/ygk/install.sh