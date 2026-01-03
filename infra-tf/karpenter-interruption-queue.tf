resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${module.eks.cluster_name}-karpenter-interruption"
  message_retention_seconds = 300
}

output "karpenter_interruption_queue_name" {
  value = aws_sqs_queue.karpenter_interruption.name
}

output "karpenter_interruption_queue_arn" {
  value = aws_sqs_queue.karpenter_interruption.arn
}
