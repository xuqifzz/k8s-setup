#!/bin/bash
set -e 
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh

systemctl status kube-nginx |grep 'Active:'
# journalctl -u kube-nginx