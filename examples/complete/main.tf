module "iam" {
  source = "../../"

  name = "platform-dev"

  create_oidc_provider = false
  oidc_provider_url    = ""

  create_cluster_role = true
  create_node_role    = true

  node_role_additional_policies = {
    ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  irsa_roles = {}

  tags = {
    Environment = "dev"
    Project     = "eks-platform"
    ManagedBy   = "terraform"
  }
}
