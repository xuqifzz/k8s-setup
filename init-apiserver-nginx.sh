#!/bin/bash
set -e 
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh

echo ">>>>> 使用yum安装gcc..."
yum install -y gcc

echo ">>>>> 下载和编译nginx..."
cd /opt/k8s/work
wget http://nginx.org/download/nginx-1.15.3.tar.gz
tar -xzf nginx-1.15.3.tar.gz
cd /opt/k8s/work/nginx-1.15.3
mkdir nginx-prefix
./configure --prefix=/opt/k8s/kube-nginx --with-stream --without-http  --without-http_uwsgi_module --without-http_scgi_module --without-http_fastcgi_module
cd /opt/k8s/work/nginx-1.15.3
make && make install
cd /opt/k8s/kube-nginx
./sbin/nginx -v
ldd ./sbin/nginx
echo ">>>>> nginx编译完毕"

cd $SETUP_HOME
cp -f conf/nginx.conf /opt/k8s/kube-nginx/conf/nginx.conf
bash replace-host-ip.sh /opt/k8s/kube-nginx/conf/nginx.conf

cp -f conf/kube-nginx.service /usr/lib/systemd/system/kube-nginx.service
systemctl daemon-reload && systemctl enable kube-nginx && systemctl restart kube-nginx




