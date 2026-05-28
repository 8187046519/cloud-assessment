output "vpc_id" {
  value = local.vpc_id
}

output "public_subnets" {
  value = local.public_subnets
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}