#!/bin/bash
set -e 
source /opt/k8s/bin/environment.sh
echo ">>>>> 部署dns插件..."
docker pull coredns/coredns:1.2.2
docker tag coredns/coredns:1.2.2 k8s.gcr.io/coredns:1.2.2
cd /opt/k8s/work/kubernetes/cluster/addons/dns/coredns
cp coredns.yaml.base coredns.yaml
source /opt/k8s/bin/environment.sh
sed -i -e "s/__PILLAR__DNS__DOMAIN__/${CLUSTER_DNS_DOMAIN}/" -e "s/__PILLAR__DNS__SERVER__/${CLUSTER_DNS_SVC_IP}/" coredns.yaml
kubectl create -f coredns.yaml
echo ">>>>> 部署dns插件完毕"
