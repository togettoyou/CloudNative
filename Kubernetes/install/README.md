所有节点执行：

```shell
curl -sSL https://raw.githubusercontent.com/togettoyou/CloudNative/main/Kubernetes/install/install.sh | bash
```

国内代理：

```shell
curl -sSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/togettoyou/CloudNative/main/Kubernetes/install/install.sh | bash
```

使用 kubeadm 创建集群：

```shell
kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository registry.aliyuncs.com/google_containers --v=5
```

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
