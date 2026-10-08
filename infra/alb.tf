resource "aws_lb" "app_alb" {
  name               = "${var.PROJECT_NAME}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    for subnet in aws_subnet.public_sn : subnet.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "${var.PROJECT_NAME}-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.PROJECT_NAME}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.PROJECT_NAME}-tg"
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  for_each = aws_instance.app

  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
