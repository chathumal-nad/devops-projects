resource "aws_lb" "alb" {
  name                             = "${var.project_name}-alb"
  load_balancer_type               = "application"
  subnets                          = var.subnets
  security_groups                  = concat(coalesce(var.security_groups, []), [aws_security_group.alb-sg.id])
  idle_timeout                     = var.idle_timeout
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_route53_record" "alb-dns-records" {
  for_each = var.domains
  zone_id  = var.dns_zone_id
  name     = each.key
  type     = "CNAME"
  ttl      = 120
  records  = [aws_lb.alb.dns_name]
  allow_overwrite = true
}