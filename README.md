<!-- BEGIN_TF_DOCS -->
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
| [aws_iam_instance_profile.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources | `string` | n/a | yes |
| <a name="input_cluster_role_additional_policies"></a> [cluster\_role\_additional\_policies](#input\_cluster\_role\_additional\_policies) | Map of additional IAM policy ARNs to attach to the EKS cluster role | `map(string)` | `{}` | no |
| <a name="input_create_cluster_role"></a> [create\_cluster\_role](#input\_create\_cluster\_role) | Whether to create an IAM role for EKS cluster | `bool` | `true` | no |
| <a name="input_create_node_role"></a> [create\_node\_role](#input\_create\_node\_role) | Whether to create an IAM role for EKS node groups | `bool` | `true` | no |
| <a name="input_create_oidc_provider"></a> [create\_oidc\_provider](#input\_create\_oidc\_provider) | Whether to create an IAM OIDC provider for EKS | `bool` | `true` | no |
| <a name="input_irsa_roles"></a> [irsa\_roles](#input\_irsa\_roles) | Map of IRSA role configurations. Each key is the role name suffix.<br/>Example:<br/>{<br/>  external\_dns = {<br/>    namespace       = "kube-system"<br/>    service\_account = "external-dns"<br/>    policy\_arns     = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]<br/>  }<br/>} | <pre>map(object({<br/>    namespace       = string<br/>    service_account = string<br/>    policy_arns     = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_node_role_additional_policies"></a> [node\_role\_additional\_policies](#input\_node\_role\_additional\_policies) | Map of additional IAM policy ARNs to attach to the EKS node group role | `map(string)` | `{}` | no |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | EKS cluster OIDC issuer URL (e.g., https://oidc.eks.region.amazonaws.com/id/EXAMPLE) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_role_arn"></a> [cluster\_role\_arn](#output\_cluster\_role\_arn) | ARN of the EKS cluster IAM role |
| <a name="output_cluster_role_name"></a> [cluster\_role\_name](#output\_cluster\_role\_name) | Name of the EKS cluster IAM role |
| <a name="output_irsa_role_arns"></a> [irsa\_role\_arns](#output\_irsa\_role\_arns) | Map of IRSA role ARNs keyed by role name |
| <a name="output_irsa_role_names"></a> [irsa\_role\_names](#output\_irsa\_role\_names) | Map of IRSA role names keyed by role name |
| <a name="output_node_instance_profile_arn"></a> [node\_instance\_profile\_arn](#output\_node\_instance\_profile\_arn) | ARN of the EKS node instance profile |
| <a name="output_node_instance_profile_name"></a> [node\_instance\_profile\_name](#output\_node\_instance\_profile\_name) | Name of the EKS node instance profile |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn) | ARN of the EKS node group IAM role |
| <a name="output_node_role_name"></a> [node\_role\_name](#output\_node\_role\_name) | Name of the EKS node group IAM role |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the IAM OIDC provider |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL of the IAM OIDC provider (without https://) |
<!-- END_TF_DOCS -->