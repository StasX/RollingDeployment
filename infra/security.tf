# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.PROJECT_NAME}-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-alb-sg"
  }
}


# Application Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.PROJECT_NAME}-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Node Exporter from monitoring"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-app-sg"
  }
}


# Monitoring Security Group
resource "aws_security_group" "monitoring_sg" {
  name        = "${var.PROJECT_NAME}-monitoring-sg"
  description = "Security group for Prometheus and Grafana"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.ADMIN_ALLOWED_CIDR]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-monitoring-sg"
  }
}

resource "aws_security_group" "ssh_sg" {
  name        = "${var.PROJECT_NAME}-ssh-sg"
  description = "SSH access to EC2 instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ADMIN_ALLOWED_CIDR]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-ssh-sg"
  }
}

resource "aws_security_group" "galera_sg" {
  name        = "${var.PROJECT_NAME}-galera-sg"
  description = "MariaDB Galera cluster communication"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Galera replication TCP"
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Galera replication UDP"
    from_port   = 4567
    to_port     = 4567
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Galera incremental state transfer"
    from_port   = 4568
    to_port     = 4568
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Galera state snapshot transfer"
    from_port   = 4444
    to_port     = 4444
    protocol    = "tcp"
    self        = true
  }

  tags = {
    Name = "${var.PROJECT_NAME}-galera-sg"
  }
}
