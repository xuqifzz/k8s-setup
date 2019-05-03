#!/bin/bash
set -e 
echo ">>>>>  查服务运行状态"
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status kube-controller-manager|grep Active"
  done

echo ">>>>> 查看输出的 metric"
netstat -lnpt|grep kube-controll
curl --cacert /opt/k8s/work/cert/ca.pem --cert /opt/k8s/work/cert/admin.pem --key /opt/k8s/work/cert/admin-key.pem https://127.0.0.1:10252/metrics

echo ">>>>> 查看当前的 leader"
kubectl get endpoints kube-controller-manager --namespace=kube-system  -o yaml



