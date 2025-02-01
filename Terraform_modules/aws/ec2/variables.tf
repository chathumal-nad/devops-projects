# Variables File: variables.tf

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0dee22c13ea7a9a67"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3a.small"
}

variable "security_group_ids" {
  description = "Security Group ID for the EC2 instance"
  type        = list(string)
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "project_name" {
  description = "Project name to tag the instance"
  type        = string
}

variable "environment" {
  description = "Environment for the instance (e.g., dev, prod, qa, stg)"
  type        = string
}

variable "instance_name" {
  description = "Whether this instance is a backend or frontend"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for the EC2 instance"
  type        = string
  default     = null
}
