variable "region" {
  description = "AWS Region"
  type        = string
}

variable "asg_arns" {
  description = "The ARN of the Auto Scaling Group"
  type        = list(string)
}

variable "values_file_path" {
  description = "The path where the generated values.yaml file should be created"
  type        = string
}
