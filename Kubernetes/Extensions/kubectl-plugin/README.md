# 用插件扩展 kubectl

参考：https://kubernetes.io/zh-cn/docs/tasks/extend-kubectl/kubectl-plugins/

原理较简单，插件实际就是一个名称以 `kubectl-` 开头的可执行文件

安装插件，只需将可执行文件移动到 `PATH` 中的任意位置即可

例如 [kubectl-lazy](https://github.com/togettoyou/kubectl-lazy)

> kubectl 扩展在生产环境的实际用途可能很少
