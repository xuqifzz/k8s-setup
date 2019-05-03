#!/bin/bash
set -e
source /opt/k8s/bin/environment.sh
echo ">>>>> 检查各 Node 上的 Pod IP 连通性"
kubectl get pods  -o wide|grep nginx-ds

POD_IPS=($(kubectl get pods  -o wide|grep nginx-ds |awk '{print $6}'))
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    for pod_ip in ${POD_IPS[@]}
      do
        ssh ${node_ip} "ping -c 1 ${pod_ip}"
      done
  done



echo ">>>>> 检查服务 IP 和端口可达性"
kubectl get svc |grep nginx-ds
CLUSTER_IP=`kubectl get svc |grep nginx-ds | awk '{print $3}'`
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh ${node_ip} "curl ${CLUSTER_IP}"
  done


echo ">>>>> 检查服务的 NodePort 可达性"
NodePort=`kubectl get svc |grep nginx-ds | awk '{print $5}' | awk -F"[:/]" '{print $2}'`
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh ${node_ip} "curl ${node_ip}:${NodePort}"
  done
