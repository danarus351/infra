terraform {
  source = find_in_parent_folders("/tf_modules/ecs")
}

locals {
  env_vars    = (read_terragrunt_config(find_in_parent_folders("env.hcl"))).locals
  common_tags = (read_terragrunt_config(find_in_parent_folders("common_tags.hcl"))).locals
  marged_tags = merge(local.env_vars, local.common_tags.common_tags)
  env         = local.env_vars.short_env
  region      = (read_terragrunt_config(find_in_parent_folders("region.hcl"))).locals.aws_region
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc/"
}

dependency "iam_role" {
  config_path = "../../fe/ecs-iam-role/"
}


inputs = {

  cluster_name  = "${local.env}-${local.env_vars.project}-ecs"
  vpc_id        = dependency.vpc.outputs.vpc_id
  subnets       = dependency.vpc.outputs.public_subnets
  ec2_role_name = dependency.iam_role.outputs.proflie_name
  tags          = local.marged_tags
}