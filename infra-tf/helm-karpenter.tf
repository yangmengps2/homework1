resource "helm_release" "karpenter_crd" {
  name       = "karpenter-crd"
  namespace  = "karpenter"

  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"

  # 版本你先不要写死（让它用最新），跑通后我们再 pin 版本
  # version  = "x.y.z"
}
