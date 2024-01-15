### 部署

所有节点执行：

```shell
curl -sSL https://raw.githubusercontent.com/togettoyou/CloudNative/main/Kubernetes/init/install.sh | bash
```

也可使用国内代理：

```shell
curl -sSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/togettoyou/CloudNative/main/Kubernetes/init/install.sh | bash
```

### 安装

使用 kubeadm 创建集群：

```shell
kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.27.2 --image-repository registry.aliyuncs.com/google_containers --v=5
```

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

### 附录

安装 Pod 网络附加组件：

- calico

    ```shell
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
    ```

- flannel

    ```shell
    kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.24.0/kube-flannel.yml
    ```

安装 Helm ：

```shell
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

containerd 设置国内代理（以腾讯云代理为例）：

```shell
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
           endpoint = ["https://mirror.ccs.tencentyun.com"]
```
