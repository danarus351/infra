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

dependency "nlb-controller" {
    config_path = "../nlb-controller/"

    mock_outputs = {
          nlb-controller_output = "mock-nlb-controller-output"
      }
}

dependency "eks_autoscaler" {
  config_path = "../eks-autoscaler/"
  mock_outputs = {
          eks_autoscaler_output = "mock-eks_autoscaler-output"
      }
}


inputs = {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  chart_version    = "5.51.3"
  namespace  = "kube-system"
  region = local.region
  values = [
    <<-EOT
  server:
    service:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    EOT
  ]
  helm_set_values = [
    {
      name = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}