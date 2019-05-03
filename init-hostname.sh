#!/bin/bash
set -e
source /tmp/k8s-setup/node-ip.sh

echo ">>>>> 配置Master hosts..."
ssh-keyscan -H $MASTER_IP  >> ~/.ssh/known_hosts
echo $NODE1_IP node1 node1 >> /etc/hosts
echo $NODE2_IP node2 node2 >> /etc/hosts

echo ">>>>> 配置node1 hosts..."
ssh-keyscan -H node1  >> ~/.ssh/known_hosts
ssh root@node1 "echo $MASTER_IP master master >> /etc/hosts"
ssh root@node1 "echo $NODE2_IP node2 node2 >> /etc/hosts"

echo ">>>>> 配置node2 hosts..."
ssh-keyscan -H node2  >> ~/.ssh/known_hosts
ssh root@node2 "echo $MASTER_IP master master >> /etc/hosts"
ssh root@node2 "echo $NODE1_IP node1 node1 >> /etc/hosts"

echo ">>>>> 配置hostname完毕"