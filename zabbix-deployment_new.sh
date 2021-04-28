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
echo os_version
#修改服务器的主机名称
hostnamectl set-hostname www.xwzjk.com

#1.给最小化的系统安装相应的文件软件包或依赖库包
yum install net-tools htop telnet curl zip tar wget git gcc expect -y
yum install net-snmp-devel libxml2-devel libcurl-devel libevent libevent-devel -y

#2.install all need's packages for mysql/postgresql database or nginx/apache server
cd /usr/local/src
wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar zxvf nginx-1.16.1.tar.gz
cd  nginx-1.16.1
./configure  --prefix=/usr/local/web_server/nginx --with-http_stub_status_module --with-http_ssl_module
make && make install
/usr/local/web_server/nginx/sbin/nginx -v
#3.nginx setup create user and group
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
#4.start nginx server
/usr/local/web_server/nginx/sbin/nginx
#5.nginx configure file

#6.install mysql services

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

#应用expect预期交互创建数据库密码及zabbix数据库
if [ $? -eq 0 ];then
{
expect <<EOF
spawn sudo $mysql -p
expect "Enter password:" {send "$passwd\r"}
expect "mysql>" {send "SET PASSWORD FOR 'root'@'localhost'='Polo.******6';show databases;\r"}
expect "mysql>" {send "quit\r"}
EOF
echo "mysql 数据库正在处理处理一大波数据请稍后........."
echo "mysql 数据库密码已经完成重置动作................."
echo "................................................."

New_password='Polo.******6'

expect <<EOF
spawn sudo $mysql -p
expect "Enter password:" {send "$New_password\r"}
expect "mysql>" {send " create user zabbix@localhost identified by 'Zabbix_##!';grant all privileges on zabbix.* to zabbix@localhost;\r"}
expect "mysql>" {send "quit\r"}
EOF

Zabbix_pwd='Zabbix_###'
echo "zabbix database setup is finished ........"
}
else
{
echo "oh my god!!! please check your's last step operation ......"
exit 0
echo "halo world!!! ...... this is the world yes or no ???? "
}
fi

#7.firewalld I/O port setup
sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
systemctl stop firewalld

#8.判断系统的版本并且根据其版本从网络下载对应的源码包
if [ -f zabbix-release-5.0.* ];then
 tar -zxvf zabbix-release-5.0.*
    cd  zabbix-5.*
       exit 0
else
{  

function zabbix_install() {
#1.安装zabbix-yum源
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all
#2.安装zabbix-server and agent
yum install zabbix-server-mysql zabbix-agent -y
#3.获取MySQL原始密码
#cat $mylogs|grep 'temporary password'|awk  ‘{print $NF}’|head –1 > /root/mysqlpassword.txt
#passwd=`cat /root/mysqlpassword.txt`
#登录MySQL 修改原始密码
#$mysql -p$passwd << EOF
#SET PASSWORD FOR 'root'@'localhost' = PASSWORD('Polo.******6');
#CREATE DATABASE service_chat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
#EOF
#用新变量来存储新密码
#4.Install Zabbix frontend
yum install centos-release-scl -y
#5.编辑配置文件 /etc/yum.repos.d/zabbix.repo and enable zabbix-frontend repository.
#sed -ri '/^enabled=/cenabled=1' /etc/yum.repos.d/zabbix.repo
nl /etc/yum.repos.d/zabbix.repo |sed -i '11d'
nl /etc/yum.repos.d/zabbix.repo |sed -i '9a enabled=1'
#yum --enablerepo=zabbix.repo 

#6.Install Zabbix frontend packages.
yum install zabbix-web-mysql-scl zabbix-nginx-conf-scl -y
#7.创建初始数据库 Run the following on your database host.

#mysql -uroot -p$New_password << EOF
#create database zabbix character set utf8 collate utf8_bin;
#create user zabbix@localhost identified by 'Zabbix_001';
#grant all privileges on zabbix.* to zabbix@localhost;
#quit;
#EOF

#8.导入初始架构和数据，系统将提示您输入新创建的密码。
expect <<EOF
spawn sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p
expect "Enter password:" {send "$Zabbix_pwd\r"}
sleep 30
expect "mysql>" {send "quit\r"}
EOF
#9.编辑配置文件 /etc/zabbix/zabbix_server.conf
cat >> /etc/zabbix/zabbix_server.conf <<EOF
DBPassword=$Zabbix_pwd
EOF

#10.为Zabbix前端配置PHP编辑配置文件 /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf, uncomment and set 'listen' and 'server_name' directives.
cat >>  /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf << EOF
listen 80;
server_name www.xwzjk.com
EOF

cat >> /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf << EOF
listen.acl_users = apache,nginx
php_value[date.timezone] = Asia/shanghai
EOF

#11.启动Zabbix server和agent进程启动Zabbix server和agent进程，并为它们设置开机自启：

systemctl restart zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm

}
zabbix_install > /root/my_zabbix_install.log
echo "my zabbix controller has been installed !!!"
}

fi




