# 控制器和 Operator 模式

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/operator/

# [client-go](https://github.com/kubernetes/client-go)

直接使用 client-go 的 Informer 机制，可自行灵活处理底层细节，就像 kube-controller-manager 那样

# [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime)

controller-runtime 是专门开发 Kubernetes 控制器的 SDK 框架，在 Informer 之上提供了更高级别的抽象，包括 Client、 Cache、
Manager、 Controller、 Webhook、 Reconciler、 Source、 EventHandler、 Predicate 等功能模块

# [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) 或 [Operator SDK](https://github.com/operator-framework/operator-sdk)

Kubebuilder 和 Operator SDK 都是社区中比较流行的用于生成 Operator 代码的脚手架工具，可以帮助开发者自动生成一些重复性的代码和资源定义，创建的项目都是使用
controller-runtime 框架
