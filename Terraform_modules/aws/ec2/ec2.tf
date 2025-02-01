# locals {
#   instance_profile_exists = length(var.iam_instance_profile) > 0
# }

resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  key_name               = var.key_name

  # iam_instance_profile = local.instance_profile_exists ? var.iam_instance_profile : null
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    tags = {
      Name = "${var.project_name}-${var.environment}-${var.instance_name}"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.instance_name}"
  }
}
