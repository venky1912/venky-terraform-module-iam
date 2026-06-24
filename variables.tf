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
# EKS OIDC Provider
################################################################################

variable "create_oidc_provider" {
  description = "Whether to create an IAM OIDC provider for EKS"
  type        = bool
  default     = true
}

variable "oidc_provider_url" {
  description = "EKS cluster OIDC issuer URL (e.g., https://oidc.eks.region.amazonaws.com/id/EXAMPLE)"
  type        = string
  default     = ""
}

################################################################################
# EKS Cluster Role
################################################################################

variable "create_cluster_role" {
  description = "Whether to create an IAM role for EKS cluster"
  type        = bool
  default     = true
}

variable "cluster_role_additional_policies" {
  description = "Map of additional IAM policy ARNs to attach to the EKS cluster role"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS Node Group Role
################################################################################

variable "create_node_role" {
  description = "Whether to create an IAM role for EKS node groups"
  type        = bool
  default     = true
}

variable "node_role_additional_policies" {
  description = "Map of additional IAM policy ARNs to attach to the EKS node group role"
  type        = map(string)
  default     = {}
}

################################################################################
# IRSA Roles
################################################################################

variable "irsa_roles" {
  description = <<-EOT
    Map of IRSA role configurations. Each key is the role name suffix.
    Example:
    {
      external_dns = {
        namespace       = "kube-system"
        service_account = "external-dns"
        policy_arns     = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
      }
    }
  EOT
  type = map(object({
    namespace       = string
    service_account = string
    policy_arns     = list(string)
  }))
  default = {}
}
