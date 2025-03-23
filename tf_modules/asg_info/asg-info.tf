data "aws_autoscaling_group" "asg_info" {
  for_each = toset(var.asg_arns)
  name     = each.value
}

# Collect ASG data in the required format
locals {
  autoscaling_groups = [
    for asg in data.aws_autoscaling_group.asg_info :
    {
      name    = asg.name
      maxSize = asg.max_size
      minSize = asg.min_size
    }
  ]
}

# Generate the values.yaml file
resource "local_file" "generated_values" {
  content = yamlencode({
    autoscalingGroups = local.autoscaling_groups
  })
  filename = var.values_file_path
}
