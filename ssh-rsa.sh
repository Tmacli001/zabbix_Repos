#!/bin/bash
password=k0a1root123
echo "hello! you are welcome !!!"
function ssh_public_keys_publish() {
echo "hello! you are welcome to use my ssh_rsa_test script!!!!!!!!!!!!"

expect <<EOF
spawn sudo ssh-keygen -t rsa
expect "Enter file in which to save the key (/root/.ssh/id_rsa):" {send "/root/.ssh/id_rsa\n"}
expect "Enter passphrase (empty for no passphrase):" {send "123456\n"}
expect "Enter same passphrase again:"  {send "123456\n"}
EOF


for ip in `cat /etc/ansible/ip.txt`;do
  expect <<EOF
  spawn sudo ssh-copy-id -i /root/.ssh/id_rsa.pub $ip
  expect "/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys  root@10.0.100.$ip's password:" {send "$password\r"}
EOF
#expect "Are you sure you want to continue connecting (yes/no)?" {send "yes\r"}
#if [ $ip -eq 0 ];then
#action "$ip" /bin/true
#else
#action "$ip" /bin/false
#fi

done
}
date >>  ssh_pkpublish.log
ssh_public_keys_publish >> ssh_pkpublish.log
echo "end" >> ssh_pkpublish.log
