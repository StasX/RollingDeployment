locals {
  app_instances = {
    app-1 = 0
    app-2 = 0
    app-3 = 1
    app-4 = 1
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.PROJECT_NAME}-key"
  public_key = file("${path.module}/../keys/${var.PROJECT_NAME}-key.pub")

  tags = {
    Name = "${var.PROJECT_NAME}-key"
  }
}

resource "aws_instance" "app" {
  for_each = local.app_instances

  ami                         = var.AMI_ID != "" ? var.AMI_ID : data.aws_ami.ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_sn[each.value].id
  associate_public_ip_address = true

  key_name             = aws_key_pair.ec2_key.key_name
  iam_instance_profile = aws_iam_instance_profile.app_profile.name

  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
    aws_security_group.ssh_sg.id,
    aws_security_group.galera_sg.id
  ]

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "${var.PROJECT_NAME}-${each.key}"
    Role = "application"
  }
}

resource "aws_instance" "monitoring" {
  ami                         = var.AMI_ID != "" ? var.AMI_ID : data.aws_ami.ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.monitoring_sn.id
  associate_public_ip_address = true

  key_name             = aws_key_pair.ec2_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.monitoring_sg.id,
    aws_security_group.ssh_sg.id
  ]

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.PROJECT_NAME}-monitoring"
    Role = "monitoring"
  }
}
