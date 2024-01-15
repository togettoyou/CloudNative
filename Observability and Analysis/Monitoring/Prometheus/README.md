### 在线Chart仓库方式

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```shell
kubectl create ns monitoring
helm install prometheus prometheus-community/prometheus -f values.yaml --version 25.8.2 -n monitoring
```

### 本地离线Chart方式

```shell
wget https://github.com/prometheus-community/helm-charts/releases/download/prometheus-25.8.2/prometheus-25.8.2.tgz
```

```shell
kubectl create ns monitoring
helm install prometheus prometheus-25.8.2.tgz -f values.yaml -n monitoring
```

其中 `values.yaml` 配置文件：

```yaml

```

### 附录
