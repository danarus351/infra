terraform {
  source = find_in_parent_folders("/tf_modules/helm_release/")
}

locals {
  region = (read_terragrunt_config(find_in_parent_folders("region.hcl"))).locals.aws_region
}

include "root" {
  path = find_in_parent_folders()
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

dependency "eks" {
  config_path = "../eks/"
}

dependency "nlb-controller-irsa" {
  config_path = "../nlb-controller-irsa/"
}





inputs = {
  name          = "aws-load-balancer-controller"
  chart         = "aws-load-balancer-controller"
  namespace     = "kube-system"
  chart_version = "1.11.0"
  repository    = "https://aws.github.io/eks-charts"
  region        = local.region
  values = [
    <<-EOT
    serviceAccount:
      annotations:
          eks.amazonaws.com/role-arn: "${dependency.nlb-controller-irsa.outputs.service_account_role_arn}"
    EOT
  ]
  helm_set_values = [
    {
      name  = "clusterName"
      value = dependency.eks.outputs.cluster_name
    },
    {
      name  = "region"
      value = local.region
    },
    {
      name  = "serviceAccount.name"
      value = dependency.nlb-controller-irsa.outputs.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = true
    }
  ]
}