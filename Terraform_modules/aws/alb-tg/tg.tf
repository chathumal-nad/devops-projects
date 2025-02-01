
resource "aws_lb_target_group" "alb_tg" {
  name     = var.tg_name
  port     = var.tg_port
  protocol = var.protocol
  vpc_id   = var.vpc_id
}


resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = var.target_id
  port             = var.target_port
}