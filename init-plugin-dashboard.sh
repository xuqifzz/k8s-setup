#!/bin/bash
set -e 
source /tmp/k8s-setup/node-ip.sh
source /opt/k8s/bin/environment.sh
echo ">>>>> 部署dashboard插件..."
docker pull fishchen/kubernetes-dashboard-amd64:v1.8.3
docker tag fishchen/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3
cd /opt/k8s/work/kubernetes/cluster/addons/dashboard

/bin/cp -f ${SETUP_HOME}/conf/dashboard-service.yaml ./dashboard-service.yaml

kubectl create -f  .


#kubectl proxy --address='localhost' --port=8086 --accept-hosts='^*$'




echo ">>>>> 创建登录 token..."
kubectl create sa dashboard-admin -n kube-system
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
ADMIN_SECRET=$(kubectl get secrets -n kube-system | grep dashboard-admin | awk '{print $1}')
DASHBOARD_LOGIN_TOKEN=$(kubectl describe secret -n kube-system ${ADMIN_SECRET} | grep -E '^token' | awk '{print $2}')
echo ${DASHBOARD_LOGIN_TOKEN}

echo ">>>>> 生成admin.pfx..."
cd /opt/k8s/work/cert
openssl pkcs12 -export -nodes -out admin.pfx -inkey admin-key.pem -in admin.pem -certfile ca.pem -passout pass:
/bin/cp -f admin.pfx /opt/k8s/kube-nginx/html/admin.pfx


echo ">>>>> 生成dashboard.kubeconfig..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=dashboard.kubeconfig

# 设置客户端认证参数，使用上面创建的 Token
kubectl config set-credentials dashboard_user \
  --token=${DASHBOARD_LOGIN_TOKEN} \
  --kubeconfig=dashboard.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=dashboard_user \
  --kubeconfig=dashboard.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=dashboard.kubeconfig
/bin/cp -f dashboard.kubeconfig /opt/k8s/kube-nginx/html/dashboard.kubeconfig
echo ">>>>> 部署dashboard插件完毕"
