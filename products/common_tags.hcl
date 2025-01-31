locals {
  common_tags = {
    ManagedBy      = "terragrunt"
    terragruntPath = "${trimprefix(get_original_terragrunt_dir(), get_parent_terragrunt_dir())}"
  }
}
