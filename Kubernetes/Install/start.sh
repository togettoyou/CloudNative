#!/bin/bash

#################### 检测系统类型 ####################

# 检测系统类型
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu 系统
    SYSTEM_TYPE="apt"
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL 系统
    SYSTEM_TYPE="yum"
else
    echo "不支持的系统类型，脚本将退出"
    exit 1
fi

#################### 准备工作 ####################

# 关闭防火墙，清理防火墙规则，设置默认转发策略
if [ "$SYSTEM_TYPE" = "apt" ]; then
    if command -v ufw &> /dev/null; then
        ufw disable
    fi
else
    systemctl stop firewalld
    systemctl disable firewalld
fi

iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
iptables -P FORWARD ACCEPT

# 关闭 swap 分区
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 关闭 SELinux (仅适用于 CentOS/RHEL)
if [ "$SYSTEM_TYPE" = "yum" ]; then
    setenforce 0
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
fi

# 转发 IPv4 并让 iptables 看到桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


#################### 部署containerd ####################

if [ "$SYSTEM_TYPE" = "apt" ]; then
    # Debian/Ubuntu 系统
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # 添加 Docker 的官方 GPG 密钥
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # 设置 Docker 仓库
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装 containerd
    apt-get update
    apt-get install -y containerd.io
else
    # CentOS/RHEL 系统
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum install containerd.io-1.6.26 -y
fi

containerd config default > /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo sed -i 's|sandbox_image = ".*"|sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"|g' /etc/containerd/config.toml

systemctl enable containerd
systemctl start containerd
systemctl status containerd


#################### 部署k8s工具 ####################

if [ "$SYSTEM_TYPE" = "apt" ]; then
    # Debian/Ubuntu 系统
    # 添加 Kubernetes 的 GPG 密钥
    curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
    
    # 添加 Kubernetes 的 apt 仓库
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
    
    apt-get update
    apt-get install -y kubelet=1.27.2-00 kubeadm=1.27.2-00 kubectl=1.27.2-00
    apt-mark hold kubelet kubeadm kubectl
else
    # CentOS/RHEL 系统
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
    
    yum install -y kubelet-1.27.2 kubeadm-1.27.2 kubectl-1.27.2
fi

systemctl enable kubelet

crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock

crictl ps

echo "Kubernetes 安装脚本执行完成！"
