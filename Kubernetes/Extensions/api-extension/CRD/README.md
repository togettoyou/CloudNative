# 定制资源

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/custom-resources/

# APIExtensionsServer

APIExtensionsServer 用于处理 CustomResourceDefinitions（CRD）和 Custom Resource（CR）的 REST
请求（自定义资源的接口）

其中的 [DiscoveryController](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_discovery_controller.go#L45)
会监听 CRD
资源的变化，动态注册 [/apis/\<group>](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_discovery_controller.go#L246)
和 [/apis/\<group>/\<version>](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_discovery_controller.go#L259-L261)
路由

- `/apis/<group>`
  ：返回的是一个 [APIGroup](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1057-L1076)
  对象

- `/apis/<group>/<version>`
  ：返回的是一个 [APIResourceList](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1148-L1154)
  对象

并且还会将 APIGroup
信息通过 [AddGroupVersion](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_discovery_controller.go#L267-L271)
方法添加到全局的 [AggregatedDiscoveryGroupManager](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiserver/pkg/server/config.go#L278)
内存对象中，以此聚合到 `/apis`
路由返回的 [APIGroupList](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1047-L1051)
对象中
