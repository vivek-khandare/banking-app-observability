terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # change if you prefer a different region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ---------------- Security groups ----------------

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Jenkins server access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-sg" }
}

resource "aws_security_group" "k3s_sg" {
  name        = "k3s-observability-sg"
  description = "k3s cluster access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  ingress {
    description = "k3s API from your own machine"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  ingress {
    description     = "k3s API from Jenkins (so the pipeline can kubectl deploy)"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  ingress {
    description = "NodePort range (app + Grafana access)"
    from_port   = 30000
    to_port     = 30010
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "k3s-observability-sg" }
}

# ---------------- Instances ----------------

resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium" # k3s + monitoring stack needs ~4GB RAM
  key_name               = "YOUR_KEY_PAIR_NAME"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | sh -
              EOF

  tags = { Name = "k3s-observability-node" }
}

resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = "YOUR_KEY_PAIR_NAME"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  root_block_device {
    volume_size = 20
  }

  # jenkins-userdata.sh must be in the same folder as this file
  user_data = file("${path.module}/jenkins-userdata.sh")

  tags = { Name = "jenkins-ci-server" }
}

# ---------------- Outputs ----------------

output "k3s_public_ip" {
  value = aws_instance.k3s_node.public_ip
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}
