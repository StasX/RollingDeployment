resource "aws_ebs_volume" "database" {
  for_each = local.app_instances

  availability_zone = aws_subnet.public_sn[each.value].availability_zone
  size              = 100
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.PROJECT_NAME}-${each.key}-database"
  }
}
