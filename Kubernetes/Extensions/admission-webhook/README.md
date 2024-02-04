# 准入 Webhook

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/reference/access-authn-authz/extensible-admission-controllers/

# Kubernetes API Server 必须通过 HTTPS 访问 Webhook Server

1. 利用 [cert-manager](https://github.com/cert-manager/cert-manager) 自动颁发证书

2. 使用 Kubernetes 集群的 CA （证书颁发机构）签发证书：自行生成 KEY（私钥）和 CSR
   （Certificate Signing Request，证书签名请求），通过创建 Kubernetes
   的 [CSR](https://v1-27.docs.kubernetes.io/zh-cn/docs/reference/access-authn-authz/certificate-signing-requests/)
   资源，取得 CRT （Certificate 的缩写，即证书），默认是 1 年有效期

   ```shell
   # 生成 KEY 和 CSR ，并确保 CN（Common Name）匹配 Webhook Server 的完全限定域名（FQDN），保存为 server.csr 和 server.key
   openssl req -new -newkey rsa:2048 -nodes -out server.csr -keyout server.key -subj "/CN=simple-webhook-server.webhook-system.svc"
   ```

   ```yaml
   apiVersion: certificates.k8s.io/v1
   kind: CertificateSigningRequest
   metadata:
     name: simple-webhook-server-csr
   spec:
     request: $(cat server.csr | base64 | tr -d '\n')
     signerName: kubernetes.io/kube-apiserver-client
     usages:
       - digital signature
       - key encipherment
       - server auth
   ```

   ```shell
   # 批准 CSR
   kubectl certificate approve simple-webhook-server-csr
   # 取得 CRT 证书，保存为 server.crt
   kubectl get csr simple-webhook-server-csr -o jsonpath='{.status.certificate}'| base64 -d > server.crt
   ```

   ```shell
   # 获取 Kubernetes 集群 CA 证书，保存为 ca.crt
   kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode > ca.crt
   ```

3. 自签证书，不依赖 Kubernetes ：同样自行生成 KEY（私钥）和 CSR
   （证书签名请求），但 Webhook Server 使用的证书不要求必须是 Kubernetes 集群的 CA 证书颁发的，可以自签名根证书作为
   CA（证书颁发机构）

   ```shell
   # 生成 KEY 和 CSR ，并确保 CN（Common Name）匹配 Webhook Server 的完全限定域名（FQDN），保存为 server.csr 和 server.key
   openssl req -new -newkey rsa:2048 -nodes -out server.csr -keyout server.key -subj "/CN=simple-webhook-server.webhook-system.svc"
   
   # 生成 10 年有效期的自签名根证书作为 CA ，保存为 ca.crt 和 ca.key
   openssl req -new -x509 -days 3650 -nodes -out ca.crt -keyout ca.key -subj "/CN=Admission Controller CA"
   # 使用 CA 和 CSR 签发 10 年有效期的 CRT 证书，保存为 server.crt
   openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
   ```

不论何种方式生成的证书，其中 `server.crt` 和 `server.key` 将用于 Webhook Server 启动 HTTPS
服务，`$(cat ca.crt | base64 | tr -d '\n')` 则作为创建 `MutatingWebhookConfiguration` 或 `ValidatingWebhookConfiguration`
资源时的 `caBundle` 字段值，该 CA 证书可用于 Kubernetes API Server 验证对 Webhook Server 的请求是否安全。例如：

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: simple-validating-webhook-configuration
webhooks:
  - name: simple-webhook-server.webhook-system
    clientConfig:
      service:
        name: simple-webhook-server
        namespace: webhook-system
        path: "/validate"
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
    rules:
      - operations: [ "CREATE", "UPDATE" ]
        apiGroups: [ "" ]
        apiVersions: [ "v1" ]
        resources: [ "pods" ]
    admissionReviewVersions: [ "v1", "v1beta1" ]
    sideEffects: None
```

- 当使用 `clientConfig.service` 时，服务器证书必须对 `<svc_name>.<svc_namespace>.svc`
  有效，即生成证书时指定 `-subj "/CN=simple-webhook-server.webhook-system.svc"`

- 若使用 `clientConfig.url` ，则不做要求
