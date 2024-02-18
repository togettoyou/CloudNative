package main

import (
	"k8s.io/client-go/listers/core/v1"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/util/workqueue"
)

type Controller struct {
	queue    workqueue.RateLimitingInterface
	lister   v1.PodLister
	informer cache.Controller
}

func NewController(
	queue workqueue.RateLimitingInterface,
	lister v1.PodLister,
	informer cache.Controller) *Controller {
	return &Controller{
		queue:    queue,
		lister:   lister,
		informer: informer,
	}
}

func (c *Controller) Run(workers int, stopCh chan struct{}) {

}
