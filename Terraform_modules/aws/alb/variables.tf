variable "project_name" {
  description = "Name of the project"
  type        = string
}
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}
variable "idle_timeout" {
  type    = number
  default = 60
}
variable "enable_deletion_protection" {
  type    = bool
  default = false
}
variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = true
}
variable "default_cert_arn" {
  type = string
  default = ""
}
variable "vpc_id" {
  type = string
}
variable "create_443_listener" {
  type    = bool
  default = false
}
variable "domains" {
  type = set(string)
  default = []
}
variable "dns_zone_id" {
  type = string
}
