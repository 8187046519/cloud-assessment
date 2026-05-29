# Cloud Application Deployment

## Overview

This project deploys a containerized web application on AWS using Terraform and ECS Fargate.

## Architecture

* AWS ECS Fargate
* Application Load Balancer
* CloudWatch Logs
* Security Groups
* Public Subnets
* VPC Networking

## Design Decisions

* ECS Fargate chosen to avoid EC2 management
* ALB used for traffic distribution
* Terraform used for Infrastructure as Code
* CloudWatch enabled for monitoring/logging

## Trade-offs

* Public subnets used for simplicity and faster deployment
* NAT Gateway/private subnets skipped to reduce complexity and cost

## Cost Optimization

* Small Fargate task size
* Minimal log retention
* Only required resources deployed

## Deployment

```bash
terraform init
terraform apply -auto-approve
```

## CI/CD

GitHub Actions pipeline validates Terraform automatically on push.
