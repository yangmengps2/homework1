# karpenter-controller-iam.tf

locals {
  karpenter_namespace = "karpenter"
  karpenter_sa_name   = "karpenter"
}

# 你的 node role（你已经创建好了）
locals {
  karpenter_node_role_arn = "arn:aws:iam::939503809934:role/helloapp-dev-karpenter-node-role"
}

# 你的 interruption queue ARN（你已经创建好了）
locals {
  karpenter_interruption_queue_arn = "arn:aws:sqs:ap-southeast-2:939503809934:helloapp-dev-karpenter-interruption"
}

# 从你现有的 OIDC provider url 推导 condition key
locals {
  oidc_issuer = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

resource "aws_iam_role" "karpenter_controller" {
  name = "${module.eks.cluster_name}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer}:sub" = "system:serviceaccount:${local.karpenter_namespace}:${local.karpenter_sa_name}"
            "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name = "${module.eks.cluster_name}-karpenter-controller-policy"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 必须：让 controller 能把你创建的 node role 传给 EC2
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = [local.karpenter_node_role_arn]
      },

      # 必须：读取 EKS 集群信息（endpoint/ca/identity 等）
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = ["*"]
      },

      # 常用：EC2 相关（先跑通；后面我们再收敛权限）
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:Describe*"
        ]
        Resource = ["*"]
      },

      # 常用：价格查询（选 instance types 会用到）
      {
        Effect   = "Allow"
        Action   = ["pricing:GetProducts"]
        Resource = ["*"]
      },

      # 推荐：interruption queue 权限（Spot/维护/中断）
      {
        Effect = "Allow"
        Action = [
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [local.karpenter_interruption_queue_arn]
      },

      # ✅ 让 Karpenter 能从 SSM Parameter Store 取 EKS Optimized AMI 的 image_id
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = ["*"]
      },

      # ✅ 有些版本在解析 AMI 时也需要 DescribeImages
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages"
        ]
        Resource = ["*"]
      }
    ]
  })
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}
