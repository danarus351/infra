output "autoscalingGroups" {
  value = [
    for asg in data.aws_autoscaling_group.asg_info : {
      name    = asg.name
      maxSize = asg.max_size
      minSize = asg.min_size
    }
  ]
}

output "generated_values_file" {
  value = local_file.generated_values.filename
}
