# 准入 Webhook

参考：https://v1-27.docs.kubernetes.io/zh-cn/docs/reference/access-authn-authz/extensible-admission-controllers/

# Kubernetes API Server 必须通过 HTTPS 访问 Webhook Server

### 方案一：自签证书

自行生成 KEY（私钥）和 CSR（Certificate Signing Request，证书签名请求），使用自签名根证书作为 CA（证书颁发机构）颁发 CRT
（Certificate 的缩写，即证书）

```shell
# 生成 KEY 和 CSR ，并确保 CN （逐步淘汰） 和 SANs 匹配 Webhook Server 的完全限定域名（FQDN），保存为 tls.csr 和 tls.key
openssl req -new -newkey rsa:2048 -nodes -out tls.csr -keyout tls.key -subj "/CN=simple-webhook-server.webhook-system.svc" -addext "subjectAltName=DNS:simple-webhook-server.webhook-system.svc"

# 生成 10 年有效期的自签名根证书作为 CA ，保存为 ca.crt 和 ca.key
openssl req -new -x509 -days 3650 -nodes -out ca.crt -keyout ca.key -subj "/CN=Admission Controller CA"
# 使用 CA 和 CSR 签发 10 年有效期的 CRT 证书，保存为 tls.crt
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt -days 3650
```

其中 `tls.crt` 和 `tls.key` 将用于 Webhook Server 启动 HTTPS 服务，`$(cat ca.crt | base64 | tr -d '\n')`
需作为创建 `MutatingWebhookConfiguration` 或 `ValidatingWebhookConfiguration` 资源时的 `caBundle` 字段值，Kubernetes API
Server 需要使用该字段值验证对 Webhook Server 的请求是否安全。例如：

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: simple-validating-webhook-configuration
webhooks:
  - name: simple-webhook-server.webhook-system.io
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
    failurePolicy: Ignore
```

> 当使用到 `clientConfig.service` 时，服务器证书才必须对 `<svc_name>.<svc_namespace>.svc` 有效
>
> 若使用 `clientConfig.url` ，则不做要求

### 方案二：利用 [cert-manager](https://github.com/cert-manager/cert-manager) 自动颁发证书

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: simple-webhook-server-issuer
  namespace: webhook-system
spec:
  selfSigned: { }
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: simple-webhook-server-cert
  namespace: webhook-system
spec:
  dnsNames:
    - simple-webhook-server.webhook-system.svc
  issuerRef:
    kind: Issuer
    name: simple-webhook-server-issuer
  secretName: simple-webhook-server-cert
```

原理同方案一，只不过所需的 `ca.crt` 、 `tls.crt` 和 `tls.key` 会自动保存在名为 `simple-webhook-server-cert` 的 secrets
中，Webhook Server Pod 可直接挂载该 secrets ，使用 `tls.crt` 和 `tls.key` 启动 HTTPS
服务。对于 `MutatingWebhookConfiguration` 或 `ValidatingWebhookConfiguration`
资源，只需要创建时添加 `cert-manager.io/inject-ca-from: webhook-system/simple-webhook-server-cert` 的 annotations
，就可以自动注入 caBundle 值，无需手动指定，例如：

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: simple-validating-webhook-configuration
  annotations:
    cert-manager.io/inject-ca-from: webhook-system/simple-webhook-server-cert
webhooks:
  - name: simple-webhook-server.webhook-system.io
    clientConfig:
      service:
        name: simple-webhook-server
        namespace: webhook-system
        path: "/validate"
    rules:
      - operations: [ "CREATE", "UPDATE" ]
        apiGroups: [ "" ]
        apiVersions: [ "v1" ]
        resources: [ "pods" ]
    admissionReviewVersions: [ "v1", "v1beta1" ]
    sideEffects: None
    failurePolicy: Ignore
```
