# venky-terraform-module-iam

Generic Terraform module for provisioning IAM resources for any workload.

## Features

- Generic IAM roles with configurable trust policies (any AWS service, cross-account, etc.)
- Custom IAM policy creation
- Instance profiles for EC2-based workloads
- OIDC providers (EKS, GitHub Actions, GitLab CI, etc.)
- Federated roles (IRSA, GitHub OIDC, any web identity provider)
- Least-privilege by default

## Usage - EKS Roles

```hcl
module "iam" {
  source = "git::https://github.com/venky1912/venky-terraform-module-iam.git?ref=v0.2.0"

  name = "platform-dev"

  roles = {
    eks-cluster = {
      trust_policy_statements = [{
        actions   = ["sts:AssumeRole"]
        principal = { Service = "eks.amazonaws.com" }
      }]
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
      ]
    }
    eks-node = {
      trust_policy_statements = [{
        actions   = ["sts:AssumeRole"]
        principal = { Service = "ec2.amazonaws.com" }
      }]
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      ]
      create_instance_profile = true
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Usage - GitHub Actions OIDC

```hcl
module "iam" {
  source = "git::https://github.com/venky1912/venky-terraform-module-iam.git?ref=v0.2.0"

  name = "ci-deploy"

  oidc_providers = {
    github = {
      url            = "https://token.actions.githubusercontent.com"
      client_id_list = ["sts.amazonaws.com"]
    }
  }

  federated_roles = {
    github-deploy = {
      provider_arn = module.iam.oidc_provider_arns["github"]
      condition_string_equals = {
        "token.actions.githubusercontent.com:sub" = "repo:venky1912/my-app:ref:refs/heads/main"
        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
      }
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}
```
