terraform {
    source = "https://github.com/cloudposse/terraform-aws-eks-iam-role.git?ref=v2.2.1"
}

include "root" {
  path = find_in_parent_folders()
}


dependency "eks" {
    config_path = "../eks/"
}

locals {
    env_vars         = (read_terragrunt_config(find_in_parent_folders("env.hcl"))).locals
    common_tags      = (read_terragrunt_config(find_in_parent_folders("common_tags.hcl"))).locals
    marged_tags      = merge(local.env_vars, local.common_tags.common_tags)

}

inputs = {
     delimiter = "-"
     service_account_name = "aws-load-balancer-controller"
     service_account_namespace = "kube-system"
     eks_cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
     aws_iam_policy_document =  [file("${get_terragrunt_dir()}/iam_policy.json")]
     tags = local.marged_tags
}