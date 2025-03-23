terraform {
  source = find_in_parent_folders("/tf_modules/vpc/")
}

include "root" {
  path = find_in_parent_folders()
}


locals {
  env_vars    = (read_terragrunt_config(find_in_parent_folders("env.hcl"))).locals
  common_tags = (read_terragrunt_config(find_in_parent_folders("common_tags.hcl"))).locals
  marged_tags = merge(local.env_vars, local.common_tags.common_tags)
  env         = local.env_vars.short_env
  region      = (read_terragrunt_config(find_in_parent_folders("region.hcl"))).locals.aws_region
  subnets     = (read_terragrunt_config(find_in_parent_folders("subnets.hcl"))).locals
  public_azs  = local.subnets.public_azs
  private_azs = local.subnets.private_azs
}

inputs = {
  vpc_name            = "${local.env_vars.project}-${local.env}-vpc"
  region              = local.region
  cdir                = "10.0.0.0/16"
  public_subnets      = local.public_azs
  private_subnets     = local.private_azs
  enable_dns_support  = true
  enable_dns_hostname = true
}