output "vpc_cni_irsa_role" {
  value = aws_iam_role.vpc_cni_irsa.arn
}

output "cloudwatch_agent_irsa_role" {
  value = aws_iam_role.cwagent_irsa.arn
}
