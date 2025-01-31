locals {
  region       = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.aws_region
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_profile  = local.account_vars.locals.aws_profile_name
  account_id   = local.account_vars.locals.aws_account_id
}

terraform {
  extra_arguments "aws_profile" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "destroy",
      "untaint",
      "output",
      "state"
    ]
    env_vars = {
      AWS_PROFILE = "${local.aws_profile}"
    }
  }
}


generate "provider" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
        provider "aws" {
        profile = "${local.aws_profile}"
        region = "${local.region}"
        }
    EOF
}

generate "backend" {
  path      = "s3-backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
        backend "s3" {
        bucket = "terraform-state-dan-${local.account_id}"
        key = "${get_path_from_repo_root()}/terraform.tfstate"
        region =  "${local.region}"
        dynamodb_table = "terraform-lock-table-dan"
        }
    }
EOF
}
