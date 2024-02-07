package apis

import (
	"encoding/json"

	apidiscoveryv2beta1 "k8s.io/api/apidiscovery/v2beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	_APIGroup = &metav1.APIGroup{
		TypeMeta:                   metav1.TypeMeta{},
		Name:                       "",
		Versions:                   nil,
		PreferredVersion:           metav1.GroupVersionForDiscovery{},
		ServerAddressByClientCIDRs: nil,
	}

	_APIGroupList = &metav1.APIGroupList{
		TypeMeta: metav1.TypeMeta{},
		Groups:   nil,
	}

	_APIResourceList = &metav1.APIResourceList{
		TypeMeta:     metav1.TypeMeta{},
		GroupVersion: "",
		APIResources: nil,
	}

	_APIGroupDiscoveryList = &apidiscoveryv2beta1.APIGroupDiscoveryList{
		TypeMeta: metav1.TypeMeta{},
		ListMeta: metav1.ListMeta{},
		Items:    nil,
	}
)

func APIGroup() []byte {
	return marshal(_APIGroup)
}

func APIGroupList() []byte {
	return marshal(_APIGroupList)
}

func APIResourceList() []byte {
	return marshal(_APIResourceList)
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
