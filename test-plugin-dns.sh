#!/bin/bash
set -e 
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
kubectl get all -n kube-system

echo ">>>>> 新建一个 Deployment"
cat > my-nginx.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF
kubectl create -f my-nginx.yaml
kubectl expose deploy my-nginx
kubectl get services --all-namespaces |grep my-nginx

echo ">>>>> 创建另一个 Pod"
cd /opt/k8s/work
cat > dnsutils-ds.yml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: dnsutils-ds
  labels:
    app: dnsutils-ds
spec:
  type: NodePort
  selector:
    app: dnsutils-ds
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: dnsutils-ds
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: dnsutils-ds
    spec:
      containers:
      - name: my-dnsutils
        image: tutum/dnsutils:latest
        command:
          - sleep
          - "3600"
        ports:
        - containerPort: 80
EOF
kubectl create -f dnsutils-ds.yml

echo ">>>>> 等待启动"
sleep 10

echo ">>>>> 查看 pod 节点"

kubectl get pods

##取得pod名称
DSNUTILS_POD_NAMES=($(kubectl get pods | grep dnsutils-ds | grep 1/1 | awk '{print $1}'))

set +e
for node_name in ${DSNUTILS_POD_NAMES[@]}
  do
    echo ">>> ${node_name} nslookup kubernetes"
    kubectl exec ${node_name} nslookup kubernetes
     echo ">>> ${node_name} nslookup my-nginx"
    kubectl exec ${node_name} nslookup my-nginx
  done
set -e