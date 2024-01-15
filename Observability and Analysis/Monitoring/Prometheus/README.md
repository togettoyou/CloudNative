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
server:
  persistentVolume:
    enabled: true
    accessModes:
      - ReadWriteOnce
    size: 8Gi
    storageClass: local-storage
kube-state-metrics:
  enabled: true
prometheus-node-exporter:
  enabled: true
alertmanager:
  enabled: false
prometheus-pushgateway:
  enabled: false
```

配置参考：https://github.com/prometheus-community/helm-charts/tree/prometheus-25.8.2/charts/prometheus

### 附录

LocalPV 方式：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-prometheus-node1
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/localpv/prometheus
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
```
