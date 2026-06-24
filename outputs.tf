################################################################################
# IAM Roles
################################################################################

output "role_arns" {
  description = "Map of IAM role ARNs"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "role_names" {
  description = "Map of IAM role names"
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

################################################################################
# Instance Profiles
################################################################################

output "instance_profile_arns" {
  description = "Map of instance profile ARNs"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.arn }
}

output "instance_profile_names" {
  description = "Map of instance profile names"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.name }
}

################################################################################
# IAM Policies
################################################################################

output "policy_arns" {
  description = "Map of custom IAM policy ARNs"
  value       = { for k, v in aws_iam_policy.this : k => v.arn }
}

################################################################################
# OIDC Providers
################################################################################

output "oidc_provider_arns" {
  description = "Map of OIDC provider ARNs"
  value       = { for k, v in aws_iam_openid_connect_provider.this : k => v.arn }
}

output "oidc_provider_urls" {
  description = "Map of OIDC provider URLs (without https://)"
  value       = { for k, v in aws_iam_openid_connect_provider.this : k => replace(v.url, "https://", "") }
}

################################################################################
# Federated Roles
################################################################################

output "federated_role_arns" {
  description = "Map of federated role ARNs"
  value       = { for k, v in aws_iam_role.federated : k => v.arn }
}

output "federated_role_names" {
  description = "Map of federated role names"
  value       = { for k, v in aws_iam_role.federated : k => v.name }
}
