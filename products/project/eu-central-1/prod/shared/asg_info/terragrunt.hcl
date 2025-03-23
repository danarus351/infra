terraform {
  source = find_in_parent_folders("/tf_modules/asg_info/")
}

locals {
  region = (read_terragrunt_config(find_in_parent_folders("region.hcl"))).locals.aws_region
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
    config_path = "../eks/"
}

inputs = {
    region  = local.region
    asg_arns = dependency.eks.outputs.eks_managed_node_groups_autoscaling_group_names	
    values_file_path = "${get_terragrunt_dir()}/generated_values.yaml"
  }