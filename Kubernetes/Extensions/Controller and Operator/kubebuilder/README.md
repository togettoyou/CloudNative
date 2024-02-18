# 使用 Kubebuilder 开发 controller

安装 Kubebuilder 脚手架工具：[v3.11.1](https://github.com/kubernetes-sigs/kubebuilder/releases/v3.11.1/)

初始化项目：

```shell
mkdir simple
cd simple
kubebuilder init --project-name simple --repo simple
```

Kubebuilder 特别适合开发 CRD + Controller ，大部分业务逻辑无关的代码都可以自动生成，例如：

```shell
kubebuilder create api --group simple.controller.io --version v1 --kind MyPod
```

参考：[book.kubebuilder.io](https://book.kubebuilder.io/)
