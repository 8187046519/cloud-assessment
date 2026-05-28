output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "public_subnets" {
  value = data.aws_subnets.default.ids
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}