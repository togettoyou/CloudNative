package apis

import (
	apidiscoveryv2beta1 "k8s.io/api/apidiscovery/v2beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	APIGroupList = &metav1.APIGroupList{
		TypeMeta: metav1.TypeMeta{},
		Groups:   nil,
	}

	APIGroupDiscoveryList = &apidiscoveryv2beta1.APIGroupDiscoveryList{
		TypeMeta: metav1.TypeMeta{},
		ListMeta: metav1.ListMeta{},
		Items:    nil,
	}
)
