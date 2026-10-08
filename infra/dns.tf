data "aws_route53_zone" "dns" {
  count = var.USE_DOMAIN ? 1 : 0

  name         = var.DOMAIN_NAME
  private_zone = false
}

resource "aws_route53_record" "app" {
  count = var.USE_DOMAIN ? 1 : 0

  zone_id = data.aws_route53_zone.dns[0].zone_id
  name    = "app.${var.DOMAIN_NAME}"
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}
