locals {
  oidc_host = replace(var.oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "app_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:histdata:histdata-app"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name}-histdata-app"
  assume_role_policy = data.aws_iam_policy_document.app_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "app_s3" {
  statement {
    sid       = "ListHistoricalData"
    actions   = ["s3:ListBucket"]
    resources = [var.data_bucket_arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["CM/*", "CD/*", "FO/*"]
    }
  }
  statement {
    sid       = "ReadHistoricalData"
    actions   = ["s3:GetObject"]
    resources = ["${var.data_bucket_arn}/CM/*", "${var.data_bucket_arn}/CD/*", "${var.data_bucket_arn}/FO/*"]
  }
}

resource "aws_iam_role_policy" "app_s3" {
  name   = "historical-data-read"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_s3.json
}

data "aws_iam_policy_document" "eso_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.name}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "external_secrets" {
  name = "read-histdata-secrets"
  role = aws_iam_role.external_secrets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = var.application_secret_arn
    }]
  })
}

data "aws_iam_policy_document" "alb_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "alb_controller" {
  name = "aws-load-balancer-controller"
  role = aws_iam_role.alb_controller.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iam:CreateServiceLinkedRole"]
        Resource = "*"
        Condition = {
          StringEquals = { "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com" }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes", "ec2:DescribeAddresses", "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways", "ec2:DescribeVpcs", "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces", "ec2:DescribeTags", "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools", "ec2:GetSecurityGroupsForVpc", "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes", "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates", "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules", "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes", "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags", "elasticloadbalancing:DescribeTrustStores",
          "elasticloadbalancing:DescribeListenerAttributes", "elasticloadbalancing:DescribeCapacityReservation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:CreateTags", "ec2:DeleteTags",
          "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener", "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteLoadBalancer", "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteListener", "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes", "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule", "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:SetIpAddressType", "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets", "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates", "elasticloadbalancing:SetWebAcl"
        ]
        Resource = "*"
      }
    ]
  })
}

# GitHub Actions role used by the application repository to push images to ECR.
data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_app_subject]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "github_ecr" {
  name = "push-histdata-image"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# GitHub Actions role used by the Kubernetes deployment repository.
data "aws_iam_policy_document" "github_deploy_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_deploy_subject]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.name}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_deploy_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "github_deploy" {
  name = "describe-eks-cluster"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect   = "Allow"
      Action   = ["eks:DescribeCluster"]
      Resource = var.eks_cluster_arn
    }]
  })
}