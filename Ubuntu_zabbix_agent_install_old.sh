#!/bin/bash
#Author polo.li
#E-mail 945626422@qq.com
#Create time 2020-10-18
#Description zabbix agent client setup
#define yourself var value....

zabbix_agent_pkgs="zabbix-release_5.0-1%2Bbionic_all.deb"
zabbix_config_files="zabbix_agentd.conf"
host_name=`hostname`
zabbix_client_info="/root/zabbix_info.txt"
host_ip=`ip addr |grep ens33 |grep inet |awk -F" " '{print $2}'`

echo $host_name >> $zabbix_client_info
echo $host_ip >> $zabbix_client_info

if [ ! -f $zabix_agent_pkgs ];then
  wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1%2Bbionic_all.deb
  echo "zabbix-agent repos is not exist .... please wait a moment,it is running download ...."
  sudo dpkg -i zabbix-release_5.0-1+bionic_all.deb
else
  sudo dpkg -i zabbix-release_5.0-1+bionic_all.deb
  echo "zabbix-agent repos is installing ......."
fi

#Update the package index:
sudo apt update
#Then install the zabbix agent
sudo apt install zabbix-agent
#use PSK protect your data
#First, generate a PSK
sudo sh -c  "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
#Show the key so you can copy it somewhere,You will need it to configure the host
cat /etc/zabbix/zabbix_agentd.psk >> $zabbix_client_info

function zabbix_setup() {

cat >> /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=192.100.100.125
ServerActive=192.100.100.125
Hostname=$host_name
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK 001
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
EOF

}

cd /etc/zabbix/

if [ -f $zabbix_config_files ]
then
  sudo mv $zabbix_config_files $zabbix_config_files.old
  echo "zabbix_agent config file copy is successful ......."
  touch $zabbix_config_files
  zabbix_setup
else
  touch $zabbix_config_files
  zabbix_setup
  echo "zabbix agent is setup ......."
fi

#save and close the file.Now you can restart the zabbix agent and set it to start at boot time.

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
zabbix_status=`sudo systemctl status zabbix-agent |grep active |head -1 |awk -F" " '{print $2}'` 

if [ $zabbix_status == "active" ]
then
  echo "zabbix agent start success ........"
else
  echo "zabbix agent start failure ........"
  echo "please return last step operation and check your os configure file , Thank you !!!"
fi

#finally please setup your system firewall
sudo ufw allow 10050/tcp
sudo systemctl restart ufw

if [ $? -eq 0 ];then
  echo "Congratulations on the successful configuration of Zzbbix Agent ...... "
else
  echo "Please check your os configuration is or not exist some errors ...... "
fi
