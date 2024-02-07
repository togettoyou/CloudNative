package apis

import (
	"encoding/json"

	apidiscoveryv2beta1 "k8s.io/api/apidiscovery/v2beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	_APIGroupList = &metav1.APIGroupList{
		TypeMeta: metav1.TypeMeta{},
		Groups:   nil,
	}

	_APIGroupDiscoveryList = &apidiscoveryv2beta1.APIGroupDiscoveryList{
		TypeMeta: metav1.TypeMeta{},
		ListMeta: metav1.ListMeta{},
		Items:    nil,
	}
)

func APIGroupList() []byte {
	return marshal(_APIGroupList)
}

func APIGroupDiscoveryList() []byte {
	return marshal(_APIGroupDiscoveryList)
}

func marshal(obj interface{}) []byte {
	bytes, err := json.Marshal(obj)
	if err != nil {
		return nil
	}
	return bytes
}
