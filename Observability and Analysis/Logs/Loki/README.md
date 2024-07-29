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
deploymentMode: SingleBinary
singleBinary:
  replicas: 1
  autoscaling:
    enabled: false
  persistence:
    enableStatefulSetAutoDeletePVC: true
    enabled: true
    size: 10Gi
    storageClass: local-storage
read:
  replicas: 0
write:
  replicas: 0
backend:
  replicas: 0
loki:
  auth_enabled: true
  server:
    http_listen_port: 3100
    grpc_listen_port: 9095
    http_server_read_timeout: 600s
    http_server_write_timeout: 600s
    grpc_server_max_recv_msg_size: 4194304
    grpc_server_max_send_msg_size: 4194304
  limits_config:
    ingestion_rate_mb: 16
    ingestion_burst_size_mb: 32
    reject_old_samples: true
    reject_old_samples_max_age: 168h
    split_queries_by_interval: 15m
    query_timeout: 2m
  ingester:
    max_chunk_age: 2m
    chunk_idle_period: 30s
    flush_check_period: 5s
  compactor:
    working_directory: /var/loki/compactor/retention
    compaction_interval: 10m
    retention_enabled: true
    retention_delete_delay: 2h
    delete_request_cancel_period: 1h
    delete_request_store: filesystem
  commonConfig:
    replication_factor: 1
    path_prefix: /var/loki
  commonStorageConfig:
    filesystem:
      chunks_directory: /var/loki/chunks
      rules_directory: /var/loki/rules
  storage:
    bucketNames:
      chunks: chunks
      ruler: ruler
      admin: admin
  storage_config:
    tsdb_shipper:
      active_index_directory: /var/loki/tsdb_shipper-active
      cache_location: /var/loki/tsdb_shipper-cache
      cache_ttl: 24h
      resync_interval: 5m
  schemaConfig:
    configs:
      - from: 2024-07-01
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: index_
          period: 24h
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
