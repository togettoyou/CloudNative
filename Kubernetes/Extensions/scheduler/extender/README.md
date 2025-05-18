# scheduler extender 调度扩展 （Webhook）

调度扩展实际是一种 Webhook ，kube-scheduler 通过 http 调用

只能作用于节点过滤（filter）、节点优先级排序（prioritize）、抢占/驱逐Pod（preempt）和节点绑定（bind）操作

参考：https://github.com/kubernetes/design-proposals-archive/blob/main/scheduling/scheduler_extender.md
