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

1. 安装 Pod 网络附加组件：

    - calico

        ```shell
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
        ```

    - flannel

        ```shell
        kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.24.0/kube-flannel.yml
        ```

2. 安装 Helm ：

   ```shell
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

3. 安装 Kubernetes Metrics Server ：

   ```shell
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.4/components.yaml
   ```

   国内无法拉取 `registry.k8s.io/metrics-server/metrics-server:v0.6.4` 镜像，可以在节点执行：

   ```shell
   ctr -n k8s.io image pull docker.io/hubmirrorbytogettoyou/registry.k8s.io.metrics-server.metrics-server:v0.6.4 && ctr -n k8s.io image tag docker.io/hubmirrorbytogettoyou/registry.k8s.io.metrics-server.metrics-server:v0.6.4 registry.k8s.io/metrics-server/metrics-server:v0.6.4
   ```

   若 metrics-server 服务一直无法 ready ，需要编辑 Deployment 增加 `--kubelet-insecure-tls` 运行参数

   ```yaml
         containers:
           - args:
               - --kubelet-insecure-tls
   ```

4. containerd 设置国内代理（以腾讯云代理为例）：

   ```toml
   [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
           [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
              endpoint = ["https://mirror.ccs.tencentyun.com"]
   ```

5. 启用 kubectl 自动补全功能

   ```shell
   yum install bash-completion
   echo 'source /usr/share/bash-completion/bash_completion' >>~/.bashrc
   echo 'source <(kubectl completion bash)' >>~/.bashrc
   echo 'alias k=kubectl' >>~/.bashrc
   echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
   source ~/.bashrc
   ```
