################################################################################
# General
################################################################################

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Roles
################################################################################

variable "roles" {
  description = <<-EOT
    Map of IAM roles to create. Supports any service or cross-account trust.
    Example:
    {
      eks-cluster = {
        description = "EKS cluster role"
        trust_policy_statements = [{
          actions   = ["sts:AssumeRole"]
          principal = { Service = "eks.amazonaws.com" }
        }]
        policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
        create_instance_profile = false
      }
    }
  EOT
  type = map(object({
    description = optional(string)
    path        = optional(string)
    trust_policy_statements = list(object({
      actions   = list(string)
      principal = map(any)
      condition = optional(any)
    }))
    policy_arns             = optional(list(string), [])
    create_instance_profile = optional(bool, false)
    max_session_duration    = optional(number, 3600)
    tags                    = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# IAM Policies
################################################################################

variable "policies" {
  description = <<-EOT
    Map of custom IAM policies to create.
    Example:
    {
      s3-read = {
        description = "Read access to S3"
        policy_json = jsonencode({...})
      }
    }
  EOT
  type = map(object({
    description = optional(string)
    path        = optional(string)
    policy_json = string
  }))
  default = {}
}

################################################################################
# OIDC Providers
################################################################################

variable "oidc_providers" {
  description = <<-EOT
    Map of OIDC providers to create. Works for EKS, GitHub Actions, GitLab, etc.
    Example:
    {
      eks = {
        url            = "https://oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE"
        client_id_list = ["sts.amazonaws.com"]
      }
      github = {
        url            = "https://token.actions.githubusercontent.com"
        client_id_list = ["sts.amazonaws.com"]
      }
    }
  EOT
  type = map(object({
    url            = string
    client_id_list = list(string)
  }))
  default = {}
}

################################################################################
# Federated Roles (IRSA, GitHub Actions OIDC, etc.)
################################################################################

variable "federated_roles" {
  description = <<-EOT
    Map of web-identity federated roles (IRSA, GitHub Actions, GitLab, etc.)
    Example:
    {
      external-dns = {
        provider_arn = "arn:aws:iam::123456789:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE"
        condition_string_equals = {
          "oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE:sub" = "system:serviceaccount:kube-system:external-dns"
          "oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE:aud" = "sts.amazonaws.com"
        }
        policy_arns = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
      }
    }
  EOT
  type = map(object({
    provider_arn            = string
    condition_string_equals = map(string)
    policy_arns             = optional(list(string), [])
    tags                    = optional(map(string), {})
  }))
  default = {}
}
