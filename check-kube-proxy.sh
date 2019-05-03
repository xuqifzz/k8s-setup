#!/bin/bash
set -e 

echo ">>>>> 检查启动结果"
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status kube-proxy|grep Active"
  done

echo ">>>>> 查看监听端口和 metrics"
netstat -lnpt|grep kube-prox

echo ">>>>> 查看 ipvs 路由规则"
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "/usr/sbin/ipvsadm -ln"
  done
