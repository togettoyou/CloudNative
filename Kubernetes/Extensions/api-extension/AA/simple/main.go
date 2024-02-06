package main

import (
	"flag"
	"fmt"
	"net/http"
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
	// GVK: simple.aa.io/v1beta1/hello

	panic(http.ListenAndServeTLS(fmt.Sprintf(":%d", port), crt, key, nil))
}
