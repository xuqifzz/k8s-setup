#!/bin/bash
set -e 
source /opt/k8s/bin/environment.sh
echo ">>>>> 部署heapster插件..."
cd /opt/k8s/work
wget https://github.com/kubernetes/heapster/archive/v1.5.4.tar.gz
tar -xzf v1.5.4.tar.gz
mv v1.5.4.tar.gz heapster-1.5.4.tar.gz

cd heapster-1.5.4/deploy/kube-config/influxdb
cp grafana.yaml{,.orig}

sed -i "s/# type: NodePort/type: NodePort/g" grafana.yaml

cp heapster.yaml{,.orig}

/bin/cp -f ${SETUP_HOME}/conf/heapster.yaml ./heapster.yaml

cd  /opt/k8s/work/heapster-1.5.4/deploy/kube-config/influxdb
kubectl create -f  .
cd ../rbac/
cp heapster-rbac.yaml{,.orig}
/bin/cp -f ${SETUP_HOME}/conf/heapster-rbac.yaml ./heapster-rbac.yaml

kubectl create -f heapster-rbac.yaml

#  kubectl get pods -n kube-system | grep -E 'heapster|monitoring'
# kubectl cluster-info

echo ">>>>> 部署heapster插件完毕"


