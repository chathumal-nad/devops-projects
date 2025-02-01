# Provision the RDS instance
resource "aws_db_instance" "mysql_instance" {
  identifier                  = "${var.project_name}-${var.environment}"
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = "gp3"
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.db_instance_class
  username                    = var.db_username
  manage_master_user_password = true
  publicly_accessible         = var.publicly_accessible
  multi_az                    = var.multi_az
  vpc_security_group_ids      = var.vpc_security_group_ids
  db_subnet_group_name        = var.db_subnet_group_name

  copy_tags_to_snapshot = true

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval # 0 - No enhanced monitoring

  storage_encrypted         = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "final-snapshot-${var.project_name}-${var.environment}"
  backup_retention_period   = 7

  backup_window      = "19:00-19:30"
  maintenance_window = "Sun:21:30-Sun:22:30"

  apply_immediately   = var.apply_immediately
  deletion_protection = var.deletion_protection

}
