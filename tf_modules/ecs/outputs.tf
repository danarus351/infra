output "ecs_cluster_name" {
  value = aws_ecs_cluster.dan_cluster.name
}

output "ecs-sg" {
  value = aws_ecs_cluster.dan_cluster.name
}

output "load_balancer_address" {
  value = aws_lb.nginx-nlb.dns_name

}
