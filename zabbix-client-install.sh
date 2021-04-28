#!/bin/bash
#author polo.li
#create time 2021-01-25 
#description zabbix client install script

host_name=`hostname`

#setup zabbix rpm backages
rpm -ivh http://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.3-1.el7.x86_64.rpm

#install zabbix client
yum -y install zabbix-agent

#set up zabbix client config files
mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old
touch /etc/zabbix/zabbix_agentd.conf
cat > /etc/zabbix/zabbix_agentd.conf << EOF
############### GENERAL PARAMETERS ###########

PidFile=/var/run/zabbix/zabbix_agentd.pid

LogFile=/var/log/zabbix-agent/zabbix_agentd.log

LogFileSize=0

########## Option : server

Server=192.100.20.188

######## Option : ListenPort

ListenPort=10050

######### Active checks related

ServerActive=192.100.20.188

######### Option : HostnameItem

Hostname=$host_name

######### Option : Include

Include=/etc/zabbix/zabbix_agentd.conf.d/

######### end  ##########

EOF

#firewall port setup
firewall-cmd --zone=public --add-port=10050/tcp --permanent
firewall-cmd --reload

#start zabbix agent
service zabbix-agent start

#zabbix agent add to automatic start service
systemctl enable zabbix-agent 


