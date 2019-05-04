#!/bin/bash
set -e 
cd /etc/ssh
cp sshd_config sshd_config.bak
sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" sshd_config
service sshd reload