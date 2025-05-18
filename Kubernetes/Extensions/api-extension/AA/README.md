# API 聚合（API Aggregation，AA）

参考：https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/

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

但 `caBundle` 不是必须的，可以通过 `insecureSkipTLSVerify: true` 禁用 TLS 证书验证（不建议）

# [apiserver-runtime](https://github.com/kubernetes-sigs/apiserver-runtime) （不推荐）

apiserver-runtime 是专门开发 AA 服务的 SDK 框架

https://github.com/kubernetes-sigs/apiserver-builder-alpha/issues/541

apiserver-runtime 是不稳定的，目前对于 AA
服务的开发，社区并没有一个较流行的库支持（类似 [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime)
那样）

# [k8s.io/apiserver](https://github.com/kubernetes/apiserver)

apiserver-runtime 实际是基于 kube-apiserver 组件的 k8s.io/apiserver 库提供扩展。建议直接学习使用该库，可以保证最大的灵活定制，不过难度也相应较大

# [Kubernetes API](https://v1-27.docs.kubernetes.io/zh-cn/docs/reference/using-api/api-concepts/)

理论上，对于简单的需求，对照着 kube-apiserver
的 [API 规范](https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/overview/kubernetes-api/)，直接手写也是可以的

重点是需要实现 API Discovery ，使 kube-apiserver 可以知道 AA 服务实现了什么 CR ，从而将请求转发过来

# AggregatorServer 的 API Discovery

当 AggregatorServer 接收到请求之后，如果发现对应的是一个 APIService 的请求，则会直接转发到对应的扩展 API 服务器上

和 [APIExtensionsServer 的 API Discovery](https://github.com/togettoyou/CloudNative/blob/main/Kubernetes/Extensions/api-extension/CRD/README.md#apiextensionsserver-%E7%9A%84-api-discovery)
类似，AggregatorServer
也有一个 [DiscoveryAggregationController](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/kube-aggregator/pkg/apiserver/handler_discovery.go#L50-L64)
会监听 APIService
资源的变化，[调用 AA 服务的 /apis 接口](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/kube-aggregator/pkg/apiserver/handler_discovery.go#L192-L207)
，然后将 AA 服务的 APIGroupDiscoveryList
对象 [添加到 kube-apiserver 全局的 AggregatedDiscoveryGroupManager](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/kube-aggregator/pkg/apiserver/handler_discovery.go#L384)
内存对象中，以此聚合到 kube-apiserver 的 `/apis` 端点

因此，对于 AA 服务，我们至少需要自行实现以下接口用于 API Discovery ：

- `/apis` ：用于给 AggregatorServer 获取 AA 的 APIGroupDiscoveryList 或 APIGroupList 对象

- `/apis/<group>` ：CRD 会动态注册，但 AA 需要自行实现，返回 APIGroup 对象

- `/apis/<group>/<version>` ：CRD 会动态注册，但 AA 需要自行实现，返回 APIResourceList 对象

> 其中 `/apis` 返回的 APIGroupList 对象，以及 `/apis/<group>` 和 `/apis/<group>/<version>` 路由是为了兼容 1.27 之前版本

另外，对于 CRD 声明的 CR 会有通用的 CRUD Handle ，但对于 AA 所创建的 CR 是需要自行实现逻辑的
