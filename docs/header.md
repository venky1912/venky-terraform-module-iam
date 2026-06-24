# venky-terraform-module-iam

Terraform module for provisioning EKS-related IAM resources.

## Features

- EKS cluster IAM role with required policies
- EKS node group IAM role with instance profile
- IAM OIDC provider for EKS (IRSA)
- IRSA roles with configurable namespace/service account scoping
- Additional policy attachment support for cluster and node roles
- Least-privilege by default

## Usage

```hcl
module "iam" {
  source = "git::https://github.com/venky1912/venky-terraform-module-iam.git?ref=v0.1.0"

  name              = "platform-dev"
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  create_cluster_role = true
  create_node_role    = true

  irsa_roles = {
    external_dns = {
      namespace       = "kube-system"
      service_account = "external-dns"
      policy_arns     = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
    }
    cert_manager = {
      namespace       = "cert-manager"
      service_account = "cert-manager"
      policy_arns     = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```
