variable "vpc_name" {}


variable "region" {
  default = "eu-central-1"
}

variable "cidr" {
  default = "10.0.0.0/16"

}


variable "public_azs" {
  type = map(string)
  default = {
    "a" = "10.0.1.0/24"
    "b" = "10.0.2.0/24"
  }
}


variable "private_azs" {
  type = map(string)
  default = {
    "a" = "10.0.3.0/24"
    "b" = "10.0.4.0/24"
  }
}

variable "enable_dns_hostname" {
  default = true
}

variable "enable_dns_support" {
  default = true

}
