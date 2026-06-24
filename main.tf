################################################################################
# EKS OIDC Provider
################################################################################

data "tls_certificate" "eks" {
  count = var.create_oidc_provider && var.oidc_provider_url != "" ? 1 : 0

  url = var.oidc_provider_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.create_oidc_provider && var.oidc_provider_url != "" ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]
  url             = var.oidc_provider_url

  tags = merge(var.tags, {
    Name = "${var.name}-eks-oidc"
  })
}

locals {
  oidc_provider_arn = var.create_oidc_provider && var.oidc_provider_url != "" ? aws_iam_openid_connect_provider.eks[0].arn : ""
  oidc_provider_url = var.oidc_provider_url != "" ? replace(var.oidc_provider_url, "https://", "") : ""
}

################################################################################
# EKS Cluster IAM Role
################################################################################

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_role ? 1 : 0

  name = "${var.name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-eks-cluster"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count = var.create_cluster_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  count = var.create_cluster_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_additional" {
  for_each = var.create_cluster_role ? var.cluster_role_additional_policies : {}

  policy_arn = each.value
  role       = aws_iam_role.cluster[0].name
}

################################################################################
# EKS Node Group IAM Role
################################################################################

resource "aws_iam_role" "node" {
  count = var.create_node_role ? 1 : 0

  name = "${var.name}-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-eks-node"
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  count = var.create_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  count = var.create_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  count = var.create_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  count = var.create_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = var.create_node_role ? var.node_role_additional_policies : {}

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_instance_profile" "node" {
  count = var.create_node_role ? 1 : 0

  name = "${var.name}-eks-node"
  role = aws_iam_role.node[0].name

  tags = var.tags
}

################################################################################
# IRSA Roles (IAM Roles for Service Accounts)
################################################################################

resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = "${var.name}-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name           = "${var.name}-${each.key}"
    ServiceAccount = each.value.service_account
    Namespace      = each.value.namespace
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = { for item in local.irsa_policy_attachments : "${item.role_key}-${item.policy_arn}" => item }

  policy_arn = each.value.policy_arn
  role       = aws_iam_role.irsa[each.value.role_key].name
}

locals {
  irsa_policy_attachments = flatten([
    for role_key, role_config in var.irsa_roles : [
      for policy_arn in role_config.policy_arns : {
        role_key   = role_key
        policy_arn = policy_arn
      }
    ]
  ])
}
