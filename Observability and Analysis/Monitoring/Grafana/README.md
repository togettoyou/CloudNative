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
helm install grafana grafana-7.2.1.tgz -f values.yaml -n monitoring
```

其中 `values.yaml` 配置文件：

```yaml
service:
  enabled: true
  type: NodePort
  nodePort: 30080
persistence:
  type: pvc
  enabled: true
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  size: 10Gi
```

配置参考：https://github.com/grafana/helm-charts/tree/grafana-7.2.1/charts/grafana

### 附录

LocalPV 方式：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-grafana-node1
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/localpv/grafana
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
```
