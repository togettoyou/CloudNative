package main

import (
	"encoding/json"
	"flag"
	"fmt"
	v1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/klog/v2"
	"net/http"
	"simple/pkg/admit"
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
	http.HandleFunc("/validating", func(w http.ResponseWriter, r *http.Request) {
		admit.Serve(w, r, admit.NewAdmitHandler(func(review v1.AdmissionReview) *v1.AdmissionResponse {
			req := review.Request
			switch req.Kind.Kind {
			case "Pod":
				var pod corev1.Pod
				if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
					msg := fmt.Sprintf("could not decode pod: %v", err)
					klog.Error(msg)
					http.Error(w, msg, http.StatusInternalServerError)
					return &v1.AdmissionResponse{
						Result: &metav1.Status{
							Message: err.Error(),
						},
					}
				}
			}
			return &v1.AdmissionResponse{
				Allowed: true,
			}
		}))
	})
	http.HandleFunc("/mutating", func(w http.ResponseWriter, r *http.Request) {
		admit.Serve(w, r, admit.NewAdmitHandler(func(review v1.AdmissionReview) *v1.AdmissionResponse {
			req := review.Request
			switch req.Kind.Kind {
			case "Pod":
				var pod corev1.Pod
				if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
					msg := fmt.Sprintf("could not decode pod: %v", err)
					klog.Error(msg)
					http.Error(w, msg, http.StatusInternalServerError)
					return &v1.AdmissionResponse{
						Result: &metav1.Status{
							Message: err.Error(),
						},
					}
				}
			}
			return &v1.AdmissionResponse{
				Allowed: true,
			}
		}))
	})
	panic(http.ListenAndServeTLS(fmt.Sprintf(":%d", port), crt, key, nil))
}
