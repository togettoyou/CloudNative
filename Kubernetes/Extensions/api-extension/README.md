# 扩展 Kubernetes API

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/

# kube-apiserver 的三个服务

- AggregatorServer：API 聚合服务。用于实现 Kubernetes API 聚合层的功能，当 AggregatorServer 接收到请求之后，如果发现对应的是一个
  APIService 的请求，则会直接转发到对应的服务上（自行编写和部署的 API 服务器，即 Aggregated APIServer ，AA），否则则委托给
  KubeAPIServer 进行处理

- KubeAPIServer：API 核心服务。实现所有 Kubernetes 内置资源的 REST API 接口（诸如 Pod 和 Service
  等资源的接口），如果请求未能找到对应的处理，则委托给 APIExtensionsServer 进行处理

- APIExtensionsServer：API 扩展服务。处理 CustomResourceDefinitions（CRD）和 Custom Resource（CR）的 REST
  请求（自定义资源的接口），如果请求仍不能被处理则委托给 404 Handler 处理

### 方案一：定制资源（Custom Resource）+ 定制控制器（Custom Controller）= Operator 模式

利用 kube-apiserver 的最后一个服务 APIExtensionsServer ，kube-apiserver 对 CR 有通用的处理，和内置资源一样，存储到
etcd 中，创建 CRD 无需编码，但往往需要结合自定义 Controller 一起使用，即 Operator 模式

### 方案二：Aggregated APIServer （AA）API 聚合服务

利用 kube-apiserver 的第一个服务 AggregatorServer ，kube-apiserver 发现收到自定义 APIService 的请求时，会转发到对应的自行编写和部署的
API 聚合服务上，相比方案一，有更强扩展性：

- 可以采用除了 etcd 之外，其它不同的存储

- 可以扩展长时间运行的子资源/端点，例如 websocket

- 可以与任何其它外部系统集成

若无特殊需求，推荐使用方案一
