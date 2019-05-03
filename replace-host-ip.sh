#!/bin/bash
set -e
source /tmp/k8s-setup/node-ip.sh
sed -i "s/192.168.100.246/$MASTER_IP/g" $1
sed -i "s/192.168.100.247/$NODE1_IP/g" $1
sed -i "s/192.168.100.248/$NODE2_IP/g" $1