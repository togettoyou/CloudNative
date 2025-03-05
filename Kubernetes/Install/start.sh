#!/bin/bash

#################### 检测系统类型 ####################

# 检测系统类型
if [ -f /etc/debian_version ]; then
    # 基于 Debian 的发行版
    SYSTEM_TYPE="apt"
elif [ -f /etc/redhat-release ]; then
    # 基于 Red Hat 的发行版
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

# 关闭 SELinux
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

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
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg

    # 添加 Docker GPG 密钥
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # 设置 Docker apt 源
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/debian/ \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    apt-get install -y containerd.io=1.6.*
else
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum install containerd.io-1.6.26 -y
fi

containerd config default > /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo sed -i 's|sandbox_image = ".*"|sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"|g' /etc/containerd/config.toml

systemctl enable containerd
systemctl restart containerd
systemctl --no-pager status containerd


#################### 部署k8s工具 ####################

if [ "$SYSTEM_TYPE" = "apt" ]; then
    # 添加 kubernetes GPG 密钥
    curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # 设置 kubernetes apt 源
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet=1.27.2-00 kubeadm=1.27.2-00 kubectl=1.27.2-00
    sudo apt-mark hold kubelet kubeadm kubectl
else
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
