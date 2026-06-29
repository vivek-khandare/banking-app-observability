resource "aws_instance" "jenkins" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/jenkins-userdata.sh")

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-jenkins"
    }
  )
}

resource "aws_instance" "k3s_server" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/k3s-server-userdata.sh")

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-k3s-server"
    }
  )
}

resource "aws_instance" "k3s_worker" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/k3s-worker-userdata.sh")

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-k3s-worker"
    }
  )

  depends_on = [
    aws_instance.k3s_server
  ]
}