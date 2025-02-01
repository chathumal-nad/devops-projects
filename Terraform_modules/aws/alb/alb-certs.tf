data "aws_acm_certificate" "alb-certificates" {
  for_each = var.domains
  domain = each.key
  statuses = ["ISSUED"]
}

resource "aws_lb_listener_certificate" "alb-certificates" {
  for_each        = var.domains
  listener_arn    = aws_lb_listener.alb-443[0].arn
  certificate_arn = data.aws_acm_certificate.alb-certificates[each.key].arn
}