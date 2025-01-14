variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. dev, prod, staging)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for PowerBI Gateway"
  type        = string
  default     = "t2.small"
}