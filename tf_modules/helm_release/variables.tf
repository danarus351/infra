variable "name" {}
variable "namespace" {
  default = "default"
}

variable "values" {
  description = "Optional Helm values file list"
  type        = list(string)
  default     = [] # This makes the `values` parameter optional
}

variable "repository" {}

variable "chart" {}

variable "chart_version" {}

variable "region" {}

variable "helm_set_values" {
  description = "List of Helm chart set values"
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  default = []
}

