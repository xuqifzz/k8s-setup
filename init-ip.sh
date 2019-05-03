#!/bin/bash
set -e
mkdir -p /tmp/k8s-setup
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

echo "export MASTER_IP=$MASTER_IP" > /tmp/k8s-setup/node-ip.sh
echo "export NODE1_IP=$NODE1_IP" >> /tmp/k8s-setup/node-ip.sh
echo "export NODE2_IP=$NODE2_IP" >> /tmp/k8s-setup/node-ip.sh
echo "export NODE_IPS=($MASTER_IP $NODE1_IP $NODE2_IP)" >> /tmp/k8s-setup/node-ip.sh
