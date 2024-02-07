package apis

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

type Hello struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec HelloSpec `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
}

type HelloSpec struct {
	Msg string `json:"msg,omitempty" protobuf:"bytes,10,opt,name=msg"`
}

var (
	__TODOHello []byte
	_TODOHello  = &Hello{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Hello",
			APIVersion: "v1beta1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "my-hello",
			Namespace: "ALL",
		},
		Spec: HelloSpec{
			Msg: "hello AA",
		},
	}
)

func TODOHello() []byte {
	if __TODOHello == nil {
		__TODOHello = marshal(_TODOHello)
	}
	return __TODOHello
}
