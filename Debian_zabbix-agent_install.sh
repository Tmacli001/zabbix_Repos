#!/bin/bash
#author polo.li
#create date 2020-10-10
#description Debian-zabbix-agent-setup script
#E-mail:945626422@qq.com

#判断安装软件源是否已经下载到本地
if [ ! -f "zabbix-release_5.0-1%2Bjessie_all.deb" ]
then
    wget http://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-1%2Bjessie_all.deb
else
  echo "Your need's zabbix-agent file is exist ......"  
fi

#安装软件源
dpkg -i  zabbix-release_5.0-1%2Bjessie_all.deb

#更新软件源
apt-get update 
#
#安装zabbix-agent
apt-get install zabbix-agent

#start zabbix-agent service
/etc/init.d/zabbix-agent start

#join in system automatic start
update-rc.d zabbix-agent defaults


