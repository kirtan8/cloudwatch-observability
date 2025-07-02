provider "aws" {
  region = var.region
}

#############################
# IAM for VPC CNI Add-on
#############################

data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider_url}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
  }
}

resource "aws_iam_role" "vpc_cni_irsa" {
  name               = "vpc-cni-irsa"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json
}

resource "aws_iam_role_policy_attachment" "vpc_cni_attach" {
  role       = aws_iam_role.vpc_cni_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#############################
# IAM for CloudWatch Agent
#############################

data "aws_iam_policy_document" "cwagent_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider_url}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

resource "aws_iam_role" "cwagent_irsa" {
  name               = "cw-observability-irsa"
  assume_role_policy = data.aws_iam_policy_document.cwagent_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cwagent_attach" {
  role       = aws_iam_role.cwagent_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#############################
# Addons
#############################

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = "v1.19.5-eksbuild.1"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.vpc_cni_irsa.arn
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = var.cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.cwagent_irsa.arn
}
