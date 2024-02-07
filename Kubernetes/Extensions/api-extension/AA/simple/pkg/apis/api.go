package apis

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var APIGroupList = &metav1.APIGroupList{
	TypeMeta: metav1.TypeMeta{},
	Groups:   nil,
}
