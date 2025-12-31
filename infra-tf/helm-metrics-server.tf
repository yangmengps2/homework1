resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  # 版本建议固定，避免未来 plan 乱飘（你也可以先不写 version）
  # version  = "3.12.2"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  # 可选：如果你希望 TF 等它部署完成
  wait = true
}
