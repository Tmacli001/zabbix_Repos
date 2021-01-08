#!/bin/bash
#Author polo.li
#Email 945626422@qq.com
#Description zabbix-setup-script
#Create time 2020-05-30 14:20

echo -e "\033[40;36m zabbix server's env mysql+nginx+php+zabbix-server....... \033[0m"
sleep 1 
echo -e "\033[40;36m ------------------Halo everyone------------------------- \033[0m"
sleep 2
echo -e "\033[40;32m ------shell script is running,please wait a moment------ \033[0m"
sleep 3
echo -e "\033[41;40m ........................................................ \033[0m"
sleep 4

#自定义变量区
os_versions=`cat /etc/redhat-release | awk '{print $1,$4-$6}'`
host_mac=`ip a show ens33|grep link|awk '{print $2}'`
host_ip=10.0.20.188
net_mask=255.255.255.0
gate_way=10.0.20.254
internet_dns=114.114.114.114
intranet_dns=10.0.1.9
echo os_version
#修改服务器的主机名称
hostnamectl set-hostname www.xwzjk.com
#主机网络配置
cp /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33.bak
cat > /etc/sysconfig/network-scripts/ifcfg-ens33 <<EOF
TYPE=Ethernet
DEVICE=ens33
NAME=ens33
BOOTPROTO=static
HWADDR=$host_mac
ONBOOT=yes
IPADDR=$host_ip
NETMASK=$net_mask
GATEWAY=$gate_way
DNS1=$internet_dns
DNS2=$intranet_dns
EOF
#restart host network service
service network restart
echo "host network is restarting ....."
sleep 3
#1.给最小化的系统安装相应的文件软件包或依赖库包
yum install epel-release net-tools htop telnet curl zip tar wget git gcc expect centos-release-scl -y
yum install net-snmp-devel libxml2-devel libcurl-devel libevent libevent-devel -y
sleep 9
#2.install all need's packages for mysql/postgresql database or nginx/apache server
cd /usr/local/src
wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar zxvf nginx-1.16.1.tar.gz
cd  nginx-1.16.1
./configure  --prefix=/usr/local/web_server/nginx --with-http_stub_status_module --with-http_ssl_module
make && make install
/usr/local/web_server/nginx/sbin/nginx -v
#nginx setup create user and group
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
#/usr/local/web_server/nginx/sbin/nginx

#3.nginx configure file
#4.install php
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webstatic-release.rpm
sudo yum install -y php72w-fpm php72w-cli php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-xml php72w-process

#5.install mysql 
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum -y install mysql80-community-release-el7-3.noarch.rpm
yum makecache
yum -y install mysql-community-server.x86_64
systemctl restart mysqld
systemctl enable mysqld

mysql="/usr/bin/mysql -uroot"
mylogs='/var/log/mysqld.log'
cat $mylogs|grep 'temporary password'|awk '{print $NF}'|head -1 > /root/mysqlpwd.txt
passwd=`cat /root/mysqlpwd.txt`
#安装expect预期交互
if [ $? -eq 0 ];then
{
expect <<EOF
spawn sudo $mysql -p
expect "Enter password:" {send "$passwd\r"}
expect "mysql>" {send "SET PASSWORD FOR 'root'@'localhost'='Polo.li123*6';show databases;\r"}
expect "mysql>" {send "quit\r"}
EOF
echo "please wait a moment ................."
echo "mysql 数据库密码已经完成重置动作......"
echo "......................................"
New_password='Polo.li123*6'
#A.获取MySQL原始密码
#cat $mylogs|grep 'temporary password'|awk  ‘{print $NF}’|head –1 > /root/mysqlpassword.txt
#passwd=`cat /root/mysqlpassword.txt`
#登录MySQL 修改原始密码
#$mysql -p$passwd << EOF
#SET PASSWORD FOR 'root'@'localhost' = PASSWORD('Polo.li123*6');
#CREATE DATABASE service_chat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
#EOF
#用新变量来存储新密码
#B.创建初始数据库 Run the following on your database host.
#mysql -uroot -p$New_password << EOF
#create database zabbix character set utf8 collate utf8_bin;
#create user zabbix@localhost identified by 'Zabbix_001';
#grant all privileges on zabbix.* to zabbix@localhost;
#quit;
#EOF
expect <<EOF
spawn sudo $mysql -p
expect "Enter password:" {send "$New_password\r"}
expect "mysql>" {send " create database zabbix character set utf8 collate utf8_bin;create user zabbix@localhost identified by 'Zabbix_001';grant all privileges on zabbix.* to zabbix@localhost;\r"}
expect "mysql>" {send "quit\r"}
EOF
echo "zabbix database created successful and setup has finished ....."
}
else
{
echo "oh my god !!!"
exit 0
echo "halo world ,please check your operator, thank you !!!"
}
fi
#6.firewalld I/O port setup
sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
#systemctl stop firewalld

#7.判断系统的版本并且根据其版本从网络下载对应的源码包
if [ -f zabbix-release-5.0.* ];then
 tar -zxvf zabbix-release-5.0.*
    cd  zabbix-5.*
	   echo "zabbix packages has exist,please check is or not continue operator !!!"
       exit 0
else
{  
function zabbix_install() {
#1.安装zabbix的yum源
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all
#2.编辑zabbix源配置文件 
#/etc/yum.repos.d/zabbix.repo and enable zabbix-frontend repository.
#sed -ri '/^enabled=/cenabled=1' /etc/yum.repos.d/zabbix.repo
nl /etc/yum.repos.d/zabbix.repo |sed -i '11d' /etc/yum.repos.d/zabbix.repo
nl /etc/yum.repos.d/zabbix.repo |sed -i '10a enabled=1'  /etc/yum.repos.d/zabbix.repo
yum makecache &\
#3.安装zabbix-server and agent
yum install zabbix-server-mysql zabbix-agent -y
#4.Install Zabbix frontend packages.
yum install zabbix-web-mysql-scl zabbix-nginx-conf-scl -y
Zabbix_pwd='Zabbix_001'
#5.导入初始架构和数据，系统将提示您输入新创建的密码。
expect <<EOF
spawn sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
expect "Enter password:" {send "$Zabbix_pwd\r"}
expect "mysql>" {send "quit\r"}
EOF
#6.编辑配置文件 /etc/zabbix/zabbix_server.conf
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak
#cat >> /etc/zabbix/zabbix_server.conf <<EOF need alter config information
sed -ri '/^#DBName=/cDBName=zabbix'   /etc/zabbix/zabbix_server.conf
sed -ri '/^#DBUser=/cDBUser=zabbix'   /etc/zabbix/zabbix_server.conf
sed -ri '/^#DBPassword=/cDBPassword=$Zabbix_pwd' /etc/zabbix/zabbix_server.conf
sed -ri '/^#DBHost=/cDBHost=localhost'      /etc/zabbix/zabbix_server.conf
sed -ri '/^#DBPort=/cDBPort=3306'       /etc/zabbix/zabbix_server.conf
sed -ri '/^#DBSocket=/cDBSocket=/var/lib/mysql/mysql.sock'   /etc/zabbix/zabbix_server.conf
#EOF

# 出现这个原因是mysql8之前的版本中加密规则是mysql_native_password,而在mysql8之后,加密规则是caching_sha2_password, 
# 解决问题方法有两种,一种是升级navicat驱动,一种是把mysql用户登录密码加密规则还原成mysql_native_password. 
# ALTER USER 'zabbix'@'localhost' IDENTIFIED BY 'Zabbix_001' PASSWORD EXPIRE NEVER;  
# ALTER USER 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Zabbix_001';
# flush privileges;

#7.为Zabbix前端配置PHP编辑配置文件 /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf, uncomment and set 'listen' and 'server_name' directives.
#cat >>  /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf << EOF 这里是变更不是追加
#listen 80;
#server_name www.xwzjk.com,10.0.20.188;
#EOF
cp /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf.bak
sed -ri '/^#listen 80;/clisten 80;'  /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf
sed -ri '/^#server_name;/cserver_name www.xwzjk.com;'  /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf

cp /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf  /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf.bak
sed -ri '/^listen.acl_users/clisten.acl_users = apache,nginx' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf 
sed -ri '/^; php_value[date.timezone]/cphp_value[date.timezone] = Asia/shanghai' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf 
#cat >> /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf << EOF
#listen.acl_users = apache,nginx
#php_value[date.timezone] = Asia/shanghai
#EOF
#8.firewalld zabbix port config
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=10050/tcp --permanent
firewall-cmd --zone=public --add-port=10051/tcp --permanent
service firewalld restart

#9.启动Zabbix server和agent进程启动Zabbix server和agent进程，并为它们设置开机自启：

systemctl restart zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm

}
zabbix_install > /root/my_zabbix_install.log
echo "my zabbix controller is installed !!!"
}
fi
echo “ you are welcome use zabbix auto-install script !!! ”
echo " end ............................."




