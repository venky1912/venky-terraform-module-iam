################################################################################
# OIDC Provider
################################################################################

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider"
  value       = try(aws_iam_openid_connect_provider.eks[0].arn, null)
}

output "oidc_provider_url" {
  description = "URL of the IAM OIDC provider (without https://)"
  value       = local.oidc_provider_url
}

################################################################################
# Cluster Role
################################################################################

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = try(aws_iam_role.cluster[0].arn, null)
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = try(aws_iam_role.cluster[0].name, null)
}

################################################################################
# Node Role
################################################################################

output "node_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = try(aws_iam_role.node[0].arn, null)
}

output "node_role_name" {
  description = "Name of the EKS node group IAM role"
  value       = try(aws_iam_role.node[0].name, null)
}

output "node_instance_profile_arn" {
  description = "ARN of the EKS node instance profile"
  value       = try(aws_iam_instance_profile.node[0].arn, null)
}

output "node_instance_profile_name" {
  description = "Name of the EKS node instance profile"
  value       = try(aws_iam_instance_profile.node[0].name, null)
}

################################################################################
# IRSA Roles
################################################################################

output "irsa_role_arns" {
  description = "Map of IRSA role ARNs keyed by role name"
  value       = { for k, v in aws_iam_role.irsa : k => v.arn }
}

output "irsa_role_names" {
  description = "Map of IRSA role names keyed by role name"
  value       = { for k, v in aws_iam_role.irsa : k => v.name }
}
