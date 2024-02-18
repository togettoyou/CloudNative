# 使用 Kubebuilder 开发 controller

安装 Kubebuilder 脚手架工具：

```shell
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/v3.11.1/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
```

初始化项目：

```shell
kubebuilder init --project-name simple --repo simple
```

参考：[book.kubebuilder.io](https://book.kubebuilder.io/)
