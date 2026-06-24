################################################################################
# IAM Roles (Generic)
################################################################################

resource "aws_iam_role" "this" {
  for_each = var.roles

  name        = "${var.name}-${each.key}"
  description = try(each.value.description, "IAM role for ${each.key}")
  path        = try(each.value.path, "/")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in each.value.trust_policy_statements : {
        Effect    = "Allow"
        Action    = statement.actions
        Principal = statement.principal
        Condition = try(statement.condition, null)
      }
    ]
  })

  max_session_duration = try(each.value.max_session_duration, 3600)

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.name}-${each.key}"
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for item in local.role_policy_attachments : "${item.role_key}-${item.policy_arn}" => item }

  policy_arn = each.value.policy_arn
  role       = aws_iam_role.this[each.value.role_key].name
}

locals {
  role_policy_attachments = flatten([
    for role_key, role_config in var.roles : [
      for policy_arn in try(role_config.policy_arns, []) : {
        role_key   = role_key
        policy_arn = policy_arn
      }
    ]
  ])
}

################################################################################
# IAM Instance Profiles
################################################################################

resource "aws_iam_instance_profile" "this" {
  for_each = { for k, v in var.roles : k => v if try(v.create_instance_profile, false) }

  name = "${var.name}-${each.key}"
  role = aws_iam_role.this[each.key].name

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })
}

################################################################################
# IAM Policies (Custom)
################################################################################

resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = "${var.name}-${each.key}"
  description = try(each.value.description, "Custom policy for ${each.key}")
  path        = try(each.value.path, "/")
  policy      = each.value.policy_json

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })
}

################################################################################
# OIDC Provider (Generic - works for EKS, GitHub Actions, etc.)
################################################################################

data "tls_certificate" "oidc" {
  for_each = var.oidc_providers

  url = each.value.url
}

resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.oidc_providers

  client_id_list  = each.value.client_id_list
  thumbprint_list = [data.tls_certificate.oidc[each.key].certificates[0].sha1_fingerprint]
  url             = each.value.url

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}-oidc"
  })
}

################################################################################
# IRSA / Federated Roles (Web Identity)
################################################################################

resource "aws_iam_role" "federated" {
  for_each = var.federated_roles

  name = "${var.name}-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = each.value.provider_arn
      }
      Condition = {
        StringEquals = each.value.condition_string_equals
      }
    }]
  })

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.name}-${each.key}"
  })
}

resource "aws_iam_role_policy_attachment" "federated" {
  for_each = { for item in local.federated_policy_attachments : "${item.role_key}-${item.policy_arn}" => item }

  policy_arn = each.value.policy_arn
  role       = aws_iam_role.federated[each.value.role_key].name
}

locals {
  federated_policy_attachments = flatten([
    for role_key, role_config in var.federated_roles : [
      for policy_arn in try(role_config.policy_arns, []) : {
        role_key   = role_key
        policy_arn = policy_arn
      }
    ]
  ])
}
