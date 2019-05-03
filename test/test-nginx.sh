#!/bin/bash
set -e
source /opt/k8s/bin/environment.sh
echo ">>>>> 检查节点状态"
kubectl get nodes

echo ">>>>> 创建测试文件"
cd /opt/k8s/work
cat > nginx-ds.yml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ds
  labels:
    app: nginx-ds
spec:
  type: NodePort
  selector:
    app: nginx-ds
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ds
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: nginx-ds
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF

echo ">>>>> 执行定义文件"
kubectl create -f nginx-ds.yml



