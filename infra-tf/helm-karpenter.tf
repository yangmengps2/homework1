resource "helm_release" "karpenter_crd" {
  name       = "karpenter-crd"
  namespace  = "karpenter"

  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"


  # 版本你先不要写死（让它用最新），跑通后我们再 pin 版本
  # version  = "x.y.z"
}

resource "helm_release" "karpenter" {
  name      = "karpenter"
  namespace = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"

  # 我们用了独立的 CRD chart
  skip_crds = true

  # 确保 CRD 先装好
  depends_on = [helm_release.karpenter_crd]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::939503809934:role/helloapp-dev-karpenter-controller-role"
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  # queue name（不是 ARN）
  set {
    name  = "settings.interruptionQueue"
    value = "helloapp-dev-karpenter-interruption"
  }

  # 你刚创建的 instance profile name（不是 ARN）
  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = "helloapp-dev-karpenter-node-instance-profile"
  }
}
