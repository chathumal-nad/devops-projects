resource "aws_security_group" "alb-sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ${var.project_name} ALB"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Allow from all sources
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Allow from all sources
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"          # Allow all protocols
  cidr_blocks       = ["0.0.0.0/0"] # Allow to all destinations
  security_group_id = aws_security_group.alb-sg.id
}