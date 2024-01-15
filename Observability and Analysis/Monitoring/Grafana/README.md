### 在线Chart仓库方式

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

```shell
kubectl create ns monitoring
helm install grafana grafana/grafana -f values.yaml --version 7.2.1 -n monitoring
```

### 本地离线Chart方式

```shell
wget https://github.com/grafana/helm-charts/releases/download/grafana-7.2.1/grafana-7.2.1.tgz
```

```shell
kubectl create ns monitoring
helm install grafana grafana/grafana -f values.yaml grafana-7.2.1.tgz -n monitoring
```

其中 `values.yaml` 配置文件：

```yaml
service:
  enabled: true
  type: NodePort
  nodePort: 33080
persistence:
  type: pvc
  enabled: true
```

配置参考：https://github.com/grafana/helm-charts/tree/grafana-7.2.1/charts/grafana
