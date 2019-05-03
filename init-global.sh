#!/bin/bash
set -e
echo ">>>>> 安装依赖包..."
echo 'PATH=/opt/k8s/bin:$PATH' >> /root/.bashrc
yum install -y epel-release
yum install -y conntrack ipvsadm ipset jq iptables curl sysstat libseccomp net-tools
/usr/sbin/modprobe ip_vs

echo ">>>>> 关闭防火墙..."
systemctl stop firewalld
systemctl disable firewalld
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
iptables -P FORWARD ACCEPT

echo ">>>>> 关闭 swap 分区..."
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo ">>>>> 关闭 SELinux..."
set +e
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
set -e

echo ">>>>> 加载内核模块..."
modprobe br_netfilter

echo ">>>>> 优化内核参数..."
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF
cp kubernetes.conf  /etc/sysctl.d/kubernetes.conf
sysctl -p /etc/sysctl.d/kubernetes.conf


echo ">>>>> 设置系统时区..."
timedatectl set-timezone Asia/Shanghai
timedatectl set-local-rtc 0
systemctl restart rsyslog
systemctl restart crond
ntpdate cn.pool.ntp.org

echo ">>>>> 关闭无关服务..."
systemctl stop postfix && systemctl disable postfix

echo ">>>>> 设置 rsyslogd 和 systemd journal..."
mkdir /var/log/journal # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent

# 压缩历史日志
Compress=yes

SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000

# 最大占用空间 10G
SystemMaxUse=10G

# 单日志文件最大 200M
SystemMaxFileSize=200M

# 日志保存时间 2 周
MaxRetentionSec=2week

# 不将日志转发到 syslog
ForwardToSyslog=no
EOF
systemctl restart systemd-journald

echo ">>>>> 创建相关目录..."
mkdir -p /opt/k8s/{bin,work} /etc/kubernetes/cert /etc/etcd/cert
echo ">>>>> 系统初始化和全局变量配置完成"




