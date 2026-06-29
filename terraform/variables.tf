variable "aws_region" {
  description = "AWS Region where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "key_pair_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}

variable "allowed_ip" {
  description = "Public IP allowed to access EC2"
  type        = string
}