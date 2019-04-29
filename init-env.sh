#!/bin/bash
set -e

getUserInput(){
    USER_INPUT=""
    while [ -z "$USER_INPUT" ]; do
        echo $1
        read USER_INPUT
    done
}


echo "开始配置节点IP..."
getUserInput "请输入MasterIP(本机):"
export MASTER_IP=$USER_INPUT

getUserInput "请输入Node1 IP:"
export NODE1_IP=$USER_INPUT

getUserInput "请输入Node2 IP:"
export NODE2_IP=$USER_INPUT




echo "配置Master SSH密钥..."
tar xzf ssh.tgz
mv .ssh/id_rsa ~/.ssh/id_rsa
mv .ssh/id_rsa.pub ~/.ssh/id_rsa.pub


echo "配置Master hosts..."
echo $NODE1_IP node1 node1 >> /etc/hosts
echo $NODE2_IP node2 node2 >> /etc/hosts

echo "配置node1 hosts..."
ssh-keyscan -H node1  >> ~/.ssh/known_hosts
ssh root@node1 "echo $MASTER_IP master master >> /etc/hosts"
ssh root@node1 "echo $NODE2_IP node2 node2 >> /etc/hosts"

echo "配置node2 hosts..."
ssh-keyscan -H node2  >> ~/.ssh/known_hosts
ssh root@node2 "echo $MASTER_IP master master >> /etc/hosts"
ssh root@node2 "echo $NODE1_IP node1 node1 >> /etc/hosts"





