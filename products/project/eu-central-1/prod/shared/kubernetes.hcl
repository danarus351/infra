dependency "eks" {
  config_path = "${dirname(find_in_parent_folders("kubernetes.hcl"))}/eks"
  mock_outputs = {
    cluster_endpoint                   = "https://mock-endpoint.eks.amazonaws.com"
    cluster_certificate_authority_data = "bW9ja2RhdGE="
    cluster_name                       = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  skip_outputs                            = false
}

locals {
  region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.aws_region
}



generate "provider_kubernetes" {
  path      = "kubernetes.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "kubernetes" {
    host                   = "${dependency.eks.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
    token                  = data.aws_eks_cluster_auth.default.token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", "${local.region}", "--cluster-name", "${dependency.eks.outputs.cluster_name}"]
    }
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "update-kubeconfig", "--region", "${local.region}", "--name", "${dependency.eks.outputs.cluster_name}"]
    }
  }

  provider "helm" {
    kubernetes {
      host                   = "${dependency.eks.outputs.cluster_endpoint}"
      cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_certificate_authority_data}")
      token                  = data.aws_eks_cluster_auth.default.token
    }
  }

  data "aws_eks_cluster_auth" "default" {
    name = "${dependency.eks.outputs.cluster_name}"
  }
  EOF
}