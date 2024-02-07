package main

import (
	"flag"
	"fmt"
	"net/http"
	"simple/pkg/apis"

	"k8s.io/klog/v2"
)

var (
	crt  string
	key  string
	port int
)

func init() {
	flag.StringVar(&crt, "tls-crt-file", "tls.crt", "CRT 证书文件")
	flag.StringVar(&key, "tls-key-file", "tls.key", "KEY 私钥文件")
	flag.IntVar(&port, "port", 443, "Webhook Server 端口")
}

func main() {
	flag.Parse()

	// APIService: v1beta1.simple.aa.io
	// GV: simple.aa.io/v1beta1

	// API Discovery
	http.HandleFunc("/apis", func(w http.ResponseWriter, r *http.Request) {
		klog.Info("API Discovery", "/apis")
		_ = apis.APIGroupList
		_ = apis.APIGroupDiscoveryList
	})
	http.HandleFunc("/apis/simple.aa.io", func(w http.ResponseWriter, r *http.Request) {
		klog.Info("API Discovery", "/apis/simple.aa.io")

	})
	http.HandleFunc("/apis/simple.aa.io/v1beta1", func(w http.ResponseWriter, r *http.Request) {
		klog.Info("API Discovery", "/apis/simple.aa.io/v1beta1")

	})

	// CR CRUD Handle
	// K: hello

	// LIST -A
	http.HandleFunc("/apis/simple.aa.io/v1beta1/hello", func(w http.ResponseWriter, r *http.Request) {

	})
	// LIST/POST by namespaces
	http.HandleFunc("/apis/simple.aa.io/v1beta1/namespaces/:ns/hello", func(w http.ResponseWriter, r *http.Request) {

	})
	// GET/PATCH/DELETE by name
	http.HandleFunc("/apis/simple.aa.io/v1beta1/namespaces/:ns/hello/:name", func(w http.ResponseWriter, r *http.Request) {

	})

	panic(http.ListenAndServeTLS(fmt.Sprintf(":%d", port), crt, key, nil))
}
