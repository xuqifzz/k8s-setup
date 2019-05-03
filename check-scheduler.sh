#!/bin/bash
set -e 
echo ">>>>>  查服务运行状态"
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status kube-scheduler|grep Active"
  done

#journalctl -u kube-scheduler

echo ">>>>> 查看输出的 metric"
netstat -lnpt|grep kube-sche
curl -s http://127.0.0.1:10251/metrics |head


echo ">>>>> 查看当前的 leader"
kubectl get endpoints kube-scheduler --namespace=kube-system  -o yaml



