resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = var.listener_arn
  priority     = var.priority
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  condition {
    host_header {
      values = var.host_header_values
    }
  }

  tags = {
    Name = var.rule_name
  }

  lifecycle {
    ignore_changes = [priority]
  }
}