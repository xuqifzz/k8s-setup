#!/bin/bash
set -e 
cd /opt/k8s/work

echo ">>>>> 检查 kube-apiserver 运行状态"
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status kube-apiserver |grep 'Active:'"
  done

echo ">>>>> 打印 kube-apiserver 写入 etcd 的数据"
source /opt/k8s/bin/environment.sh
export ETCDCTL_API=3 
etcdctl \
    --endpoints=${ETCD_ENDPOINTS} \
    --cacert=/opt/k8s/work/cert/ca.pem \
    --cert=/opt/k8s/work/cert/etcd.pem \
    --key=/opt/k8s/work/cert/etcd-key.pem \
    get /registry/ --prefix --keys-only

echo ">>>>> 检查集群信息"
kubectl cluster-info

kubectl get all --all-namespaces
kubectl get componentstatuses

echo ">>>>> 检查 kube-apiserver 监听的端口"
netstat -lnpt|grep kube-api