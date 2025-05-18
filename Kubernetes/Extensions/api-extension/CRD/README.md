# 定制资源定义（CustomResourceDefinitions，CRD）

参考：https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/api-extension/custom-resources/

# APIExtensionsServer 的 API Discovery

APIExtensionsServer 用于处理 CustomResourceDefinitions（CRD）和 Custom Resource（CR）的 REST
请求（自定义资源的通用处理接口）

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

并且还会将 GroupVersion 和 Resources
信息通过 [AddGroupVersion](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_discovery_controller.go#L267-L271)
方法添加到全局的 [AggregatedDiscoveryGroupManager](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiserver/pkg/server/config.go#L278)
内存对象中，以此聚合到 `/apis`
路由返回的 [APIGroupList](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1047-L1051)
或 [APIGroupDiscoveryList](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/api/apidiscovery/v2beta1/types.go#L33-L41)
对象中

> APIGroupDiscoveryList 是 [1.26 新增的 API](https://github.com/kubernetes/enhancements/issues/3352) （默认关闭）, 在 1.27
> 默认开启
>
> APIGroupDiscoveryList = APIGroupList + APIResourceList
>
> 作用：减少请求次数，直接请求 `/apis` 端点一次性获取到 APIGroupDiscoveryList 对象
>
> v1.26 或之前版本需要请求 `/apis` 获取 APIGroupList 对象，随后再继续请求 `/apis/<group>` 和 `/apis/<group>/<version>`
> 端点获取到所有的 APIResourceList 对象
>
> 可以通过判断 header 是否有 `Accept: application/json;as=APIGroupDiscoveryList;v=v2beta1;g=apidiscovery.k8s.io` 来区分是请求
> APIGroupDiscoveryList 还是 APIGroupList 对象

### 流程演示

1. 创建 CRD ：

```shell
[root@node1 ~]# k apply -f crd.yaml 
customresourcedefinition.apiextensions.k8s.io/crontabs.simple.extension.io created
[root@node1 ~]# 
```

2. 查看 CR ，同时调整日志级别显示所请求的资源

```shell
[root@node1 ~]# k get CronTab -v 6
I0207 15:20:44.379006   13196 loader.go:373] Config loaded from file:  /root/.kube/config
I0207 15:20:44.387614   13196 discovery.go:214] Invalidating discovery information
I0207 15:20:44.396388   13196 round_trippers.go:553] GET https://10.0.8.17:6443/api?timeout=32s 200 OK in 8 milliseconds
I0207 15:20:44.399674   13196 round_trippers.go:553] GET https://10.0.8.17:6443/apis?timeout=32s 200 OK in 1 milliseconds
I0207 15:20:44.407886   13196 round_trippers.go:553] GET https://10.0.8.17:6443/apis/simple.extension.io/v1/namespaces/default/crontabs?limit=500 200 OK in 1 milliseconds
No resources found in default namespace.
[root@node1 ~]# 
```

可以看到，首先会请求 `/api` 路由（核心 API ，没有 G 组的概念，只有 V 版本和 K 资源），返回的同样是 `APIGroupList` 或
`APIGroupDiscoveryList` 对象（这里是 `APIGroupDiscoveryList` ），对于 K 为 `CronTab` 的 CR 资源，肯定无法在此发现

所以会接着继续请求 `/apis` 路由，从这里就可以找到 K 为 `CronTab` 所对应的 G 和 V
了，即最终请求 `/apis/simple.extension.io/v1/namespaces/default/crontabs`
路由（ [CR 通用的 CRUD Handle 逻辑](https://github.com/kubernetes/kubernetes/blob/v1.27.2/staging/src/k8s.io/apiextensions-apiserver/pkg/apiserver/customresource_handler.go#L225-L360)）

如果想显示详细的请求内容，可以调整日志级别为 `-v 9`
