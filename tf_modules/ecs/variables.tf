variable "cluster_name" {}
variable "vpc_id" {}
variable "subnets" {}
variable "ec2_role_name" {}
variable "key_path" {
  default = "~/.ssh/id_rsa.pub"

}
