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

dependency "autoscaler-irsa" {
  config_path = "../autoscaler-irsa/"
}

dependency "asg_info" {
  config_path = "../asg_info/"
}


inputs = {
  name          = "cluster-autoscaler"
  chart         = "cluster-autoscaler"
  namespace     = "kube-system"
  chart_version = "9.46.3"
  repository    = "https://kubernetes.github.io/autoscaler"
  region        = local.region
  values = [
    <<-EOT
    rbac:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: "${dependency.autoscaler-irsa.outputs.service_account_role_arn}"
    EOT
  ]
  helm_set_values = [
    {
        name  = "autoDiscovery.clusterName"
        value = dependency.eks.outputs.cluster_name
    },
    {
      name  = "serviceAccount.name"
      value = dependency.autoscaler-irsa.outputs.service_account_role_name
    },
    {
        name  = "awsRegion"
        value = local.region
    },
    {
        name  = "extraArgs.balance-similar-node-groups"
        value = "true"
    },

    {
        name  = "extraArgs.skip-nodes-with-local-storage"
        value = "false"
    },
    {
        name  = "extraArgs.expander"
        value = "random"
    }
  ]
}