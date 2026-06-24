<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.federated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.federated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources | `string` | n/a | yes |
| <a name="input_federated_roles"></a> [federated\_roles](#input\_federated\_roles) | Map of web-identity federated roles (IRSA, GitHub Actions, GitLab, etc.)<br/>Example:<br/>{<br/>  external-dns = {<br/>    provider\_arn = "arn:aws:iam::123456789:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE"<br/>    condition\_string\_equals = {<br/>      "oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE:sub" = "system:serviceaccount:kube-system:external-dns"<br/>      "oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE:aud" = "sts.amazonaws.com"<br/>    }<br/>    policy\_arns = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]<br/>  }<br/>} | <pre>map(object({<br/>    provider_arn            = string<br/>    condition_string_equals = map(string)<br/>    policy_arns             = optional(list(string), [])<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_oidc_providers"></a> [oidc\_providers](#input\_oidc\_providers) | Map of OIDC providers to create. Works for EKS, GitHub Actions, GitLab, etc.<br/>Example:<br/>{<br/>  eks = {<br/>    url            = "https://oidc.eks.eu-west-1.amazonaws.com/id/EXAMPLE"<br/>    client\_id\_list = ["sts.amazonaws.com"]<br/>  }<br/>  github = {<br/>    url            = "https://token.actions.githubusercontent.com"<br/>    client\_id\_list = ["sts.amazonaws.com"]<br/>  }<br/>} | <pre>map(object({<br/>    url            = string<br/>    client_id_list = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Map of custom IAM policies to create.<br/>Example:<br/>{<br/>  s3-read = {<br/>    description = "Read access to S3"<br/>    policy\_json = jsonencode({...})<br/>  }<br/>} | <pre>map(object({<br/>    description = optional(string)<br/>    path        = optional(string)<br/>    policy_json = string<br/>  }))</pre> | `{}` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Map of IAM roles to create. Supports any service or cross-account trust.<br/>Example:<br/>{<br/>  eks-cluster = {<br/>    description = "EKS cluster role"<br/>    trust\_policy\_statements = [{<br/>      actions   = ["sts:AssumeRole"]<br/>      principal = { Service = "eks.amazonaws.com" }<br/>    }]<br/>    policy\_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]<br/>    create\_instance\_profile = false<br/>  }<br/>} | <pre>map(object({<br/>    description = optional(string)<br/>    path        = optional(string)<br/>    trust_policy_statements = list(object({<br/>      actions   = list(string)<br/>      principal = map(any)<br/>      condition = optional(any)<br/>    }))<br/>    policy_arns             = optional(list(string), [])<br/>    create_instance_profile = optional(bool, false)<br/>    max_session_duration    = optional(number, 3600)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_federated_role_arns"></a> [federated\_role\_arns](#output\_federated\_role\_arns) | Map of federated role ARNs |
| <a name="output_federated_role_names"></a> [federated\_role\_names](#output\_federated\_role\_names) | Map of federated role names |
| <a name="output_instance_profile_arns"></a> [instance\_profile\_arns](#output\_instance\_profile\_arns) | Map of instance profile ARNs |
| <a name="output_instance_profile_names"></a> [instance\_profile\_names](#output\_instance\_profile\_names) | Map of instance profile names |
| <a name="output_oidc_provider_arns"></a> [oidc\_provider\_arns](#output\_oidc\_provider\_arns) | Map of OIDC provider ARNs |
| <a name="output_oidc_provider_urls"></a> [oidc\_provider\_urls](#output\_oidc\_provider\_urls) | Map of OIDC provider URLs (without https://) |
| <a name="output_policy_arns"></a> [policy\_arns](#output\_policy\_arns) | Map of custom IAM policy ARNs |
| <a name="output_role_arns"></a> [role\_arns](#output\_role\_arns) | Map of IAM role ARNs |
| <a name="output_role_names"></a> [role\_names](#output\_role\_names) | Map of IAM role names |
<!-- END_TF_DOCS -->