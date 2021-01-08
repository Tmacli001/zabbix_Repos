#!/bin/bash
#author polo.li
#e-mail 945626422@qq.com
#date 2020-09-25 12:20:30
#description zabbix_ansible_shell script

function zabbix_agent_clients_install () {

#install rpm soft packages
ansible zabbix-agent-clients -m yum -a 'name=rpm state=present'

ansible zabbix-agent-clients -m copy -a 'src=/etc/ansible/zabbix_rpm_install.sh dest=/root/'

ansible zabbix-agent-clients -m shell -a 'chmod a+x /root/zabbix_rpm_install.sh'

ansible zabbix-agent-clients -m shell -a '/bin/bash /root/zabbix_rpm_install.sh'

#change yum repos for zabbix-agent-clients is installed
#ansible zabbix-agent-clients -m shell -a 'rpm -ivh http://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.3-1.el7.x86_64.rpm'
echo "zabbix-agent repos is update !!!"

#install zabbix-agent
#ansible  zabbix-agent-clients -m shell -a 'yum -y install zabbix-agent'
ansible  zabbix-agent-clients -m yum -a 'name=zabbix-agent state=present'
echo "zabbix-agent-clients is installing ......."

#setup open start zabbix-agnet
ansible zabbix-agent-clients -m shell -a 'systemctl start zabbix-agent'
echo "zabbix-agent-clients is running ....."

#check system is or not start zabbix-agent service's port
ansible zabbix-agent-clients -m shell -a 'systemctl enable zabbix_agent.service'
echo "zabbix agent clients is add open starting ....... "

#exchange zabbix-agnet configure docs
#backup origin config file
#1先把本地zabbix-agent配置文件备份，然后修改Server='主控端IP'
#2运用ansible copy模块把修改好的配置文件推送到被监控端所有服务器
#3重启zabbix-agent
#cp  /etc/zabbix/zabbix_agentd.conf ./

#backup zabbix_agentd.conf file 
ansible zabbix-agent-clients -m shell -a 'mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd_old.conf'
echo "zabbix configure file is backup ......"

#remote copy zabbix-agent configure file to other hosts
ansible zabbix-agent-clients -m copy -a 'src=/root/zabbix_agentd.conf dest=/etc/zabbix/'
echo "zabbix agnet clients file is update ......."

#restart zabbix-agent clients
ansible zabbix-agent-clients -m shell -a 'systemctl restart zabbix-agent'
echo "zabbix agent clients is restarting ......."

#check zabbix-agent service is or not is running !!!
ansible  zabbix-agent-clients -m shell -a 'netstat -ltunp |grep zabbix-agentd'
echo "zabbix agent client port is checking ....."

}

echo "zabbix agent clients install log" >> /etc/ansible/zabbix_agent_clients_install.log
date >> /etc/ansible/zabbix_agent_clients_install.log
zabbix_agent_clients_install >> /etc/ansible/zabbix_agent_clients_install.log
echo "The zabbix-agent client install script is run end ..........."
