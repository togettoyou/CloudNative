### 在线Chart仓库方式

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

```shell
kubectl create ns monitoring
helm install loki grafana/loki -f values.yaml --version 6.7.3 -n monitoring
```

### 本地离线Chart方式

```shell
wget https://github.com/grafana/helm-charts/releases/download/helm-loki-6.7.3/loki-6.7.3.tgz
```

```shell
kubectl create ns monitoring
helm install loki loki-6.7.3.tgz -f values.yaml -n monitoring
```

其中 `values.yaml` 配置文件：

```yaml

```

配置参考：https://github.com/grafana/loki/tree/helm-loki-6.7.3/production/helm/loki

### 附录

1. LocalPV 参考：

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: local-pv-loki-node1
   spec:
     capacity:
       storage: 10Gi
     volumeMode: Filesystem
     accessModes:
       - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     storageClassName: local-storage
     local:
       path: /mnt/localpv/loki
     nodeAffinity:
       required:
         nodeSelectorTerms:
           - matchExpressions:
               - key: kubernetes.io/hostname
                 operator: In
                 values:
                   - node1
   ```
