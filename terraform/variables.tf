variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "banking-app-observability"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_pair_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}

variable "allowed_ip" {
  description = "Your Public IP with /32 (Example: 103.xxx.xxx.xxx/32)"
  type        = string
}
