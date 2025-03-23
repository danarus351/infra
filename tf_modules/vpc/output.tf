output "vpc_id" {
  value = aws_vpc.ecs_vpc.id
}

output "public_subnet" {
  value = aws_subnet.public_subnet
}

output "private_subnet" {
  value = aws_subnet.private_subnet
}


output "public_subnets_id" {
  value = values(aws_subnet.public_subnet)[*].id
}

output "private_subnets_id" {
  value = values(aws_subnet.private_subnet)[*].id
}
