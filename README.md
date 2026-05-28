# Cloud Assessment Project

## Overview
This project demonstrates a full DevOps CI/CD pipeline using AWS and Terraform.

## Architecture
- GitHub → Source Code Management
- GitHub Actions → CI/CD Pipeline
- Terraform → Infrastructure as Code
- AWS ECS → Container Deployment
- AWS ECR → Docker Image Registry
- AWS ALB → Load Balancer
- AWS VPC → Networking
- CloudWatch → Logging

## Services Used
- AWS ECS (Fargate)
- AWS ECR
- AWS VPC
- AWS ALB
- AWS CloudWatch
- Terraform
- GitHub Actions

## Deployment Flow
1. Code pushed to GitHub
2. GitHub Actions triggered
3. Terraform runs infrastructure deployment
4. Docker image deployed on ECS
5. ALB exposes application

## Application
Flask app running on port 5000.

## Output
Public URL is generated via ALB DNS.

## Author
Cloud DevOps Project