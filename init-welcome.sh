#!/bin/bash
set -e 
source /tmp/k8s-setup/node-ip.sh
source /opt/k8s/bin/environment.sh
echo ">>>>> 生成欢迎页..."
sleep 5

/bin/cp -f conf/index.html /opt/k8s/kube-nginx/html/index.html 
DASHBOARD_ADDR=`kubectl cluster-info | grep kubernetes-dashboard | awk '{print $5}' | sed 's/\x1b\[[0-9;]*m//g' | sed "s/8443/6443/g"`
GRAFANA_ADDR=`kubectl cluster-info | grep monitoring-grafana  | awk '{print $5}' | sed 's/\x1b\[[0-9;]*m//g' `

sed -i "s?##DASHBOARD_ADDR##?$DASHBOARD_ADDR?g" /opt/k8s/kube-nginx/html/index.html 
sed -i "s?##GRAFANA_ADDR##?$GRAFANA_ADDR?g" /opt/k8s/kube-nginx/html/index.html 

echo ">>>>> K8S集群已经搭建完成,请访问以下地址:"
echo "http://${MASTER_IP}/index.html"

