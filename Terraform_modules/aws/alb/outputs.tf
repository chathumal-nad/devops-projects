output "alb_listener_443_arn" {
  value = var.create_443_listener ? aws_lb_listener.alb-443[0].arn : null
}

output "alb_listener_80_arn" {
  value = aws_lb_listener.alb-80.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}