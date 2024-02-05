# 控制器和 Operator 模式

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/operator/

# [controller-runtime](https://github.com/kubernetes-sigs/controller-runtime)

controller-runtime 是专门开发 Kubernetes 控制器的 SDK 框架

社区中比较流行的用于生成 Operator 代码的工具有：
[Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
和 [Operator SDK](https://github.com/operator-framework/operator-sdk) ，它们生成的代码都使用了 controller-runtime 框架
