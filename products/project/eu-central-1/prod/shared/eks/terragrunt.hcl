terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v20.34.0"
}


locals {
  env_vars         = (read_terragrunt_config(find_in_parent_folders("env.hcl"))).locals
  common_tags      = (read_terragrunt_config(find_in_parent_folders("common_tags.hcl"))).locals
  marged_tags      = merge(local.env_vars, local.common_tags.common_tags)
  env              = local.env_vars.short_env
  region           = (read_terragrunt_config(find_in_parent_folders("region.hcl"))).locals.aws_region
  caller_identity  = jsondecode(run_cmd("aws", "sts", "get-caller-identity", "--output", "json"))
  current_role_arn = local.caller_identity.Arn
}


include "root" {
  path = find_in_parent_folders()
}


dependency "vpc" {
  config_path = "../vpc/"
}


inputs = {
  cluster_version                          = local.env_vars.cluster_version
  cluster_name                             = "${local.env_vars.project}-${local.env}-eks"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnets_id
  eks_managed_node_groups = {
    main = {
      instance_types = ["t2.micro"]
      min_size = 2
      max_size = 10
      desired_size = 3
      create_iam_role    = true
      iam_role_name      = "eks-node-role"
      capacity_type = "ON_DEMAND"
      enable_auto_repair = true
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      }
      tags = {
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "k8s.io/cluster-autoscaler/${local.env_vars.project}-${local.env}-eks" = "owned"
      }
    }
  }
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true
  }