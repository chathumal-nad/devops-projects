variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for the RDS instance (in GB)"
  type        = number
  default     = 25
}

variable "engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "8.0.39"
}

variable "db_instance_class" {
  description = "Instance class (e.g., db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible"
  type        = bool
}

variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Subnet group name for the RDS instance"
  type        = string
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 0
}

variable "apply_immediately" {
  default = true
  type    = bool
}

variable "deletion_protection" {
  type    = bool
  default = false
}
