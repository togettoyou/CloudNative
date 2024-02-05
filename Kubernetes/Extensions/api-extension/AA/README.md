# Aggregated APIServer （AA）API 聚合服务

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/

# Kubernetes API Server 必须通过 HTTPS 访问扩展 API 服务器（Extension API Server）

参考：[admission-webhook](https://github.com/togettoyou/CloudNative/blob/main/Kubernetes/Extensions/admission-webhook/README.md)

其中 `tls.crt` 和 `tls.key` 将用于 Extension API Server 启动 HTTPS 服务， `$(cat ca.crt | base64 | tr -d '\n')` 需作为创建
APIService 资源时的 caBundle 字段值，例如：

```yaml
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: <注释对象名称>
spec:
  group: <扩展 Apiserver 的 API 组名>
  version: <扩展 Apiserver 的 API 版本>
  groupPriorityMinimum: <APIService 对应组的优先级, 参考 API 文档>
  versionPriority: <版本在组中的优先排序, 参考 API 文档>
  service:
    namespace: <拓展 Apiserver 服务的名字空间>
    name: <拓展 Apiserver 服务的名称>
  caBundle: <PEM 编码的 CA 证书，用于对 Webhook 服务器的证书签名>
```

# [apiserver-runtime](https://github.com/kubernetes-sigs/apiserver-runtime) （不推荐）

apiserver-runtime 是专门开发 Kubernetes 聚合 API 的 SDK 框架

https://github.com/kubernetes-sigs/apiserver-builder-alpha/issues/541

apiserver-runtime 是不稳定的，目前对于聚合 API
的开发，社区并没有一个较流行的库支持（类似 [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime) 那样）

# [k8s.io/apiserver](https://github.com/kubernetes/apiserver)

apiserver-runtime 实际也是基于 kube-apiserver 组件的 k8s.io/apiserver 库提供扩展。建议直接学习使用该库，可以保证最大的灵活定制，不过难度也相应较大
