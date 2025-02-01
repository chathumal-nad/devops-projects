variable "target_id" {
  type = string
}
variable "target_port" {
  type = number
  default = 80
}
variable "tg_name" {
  type = string
}
variable "tg_port" {
  type = number
  default = 80
}
variable "protocol" {
  type = string
  default = "HTTP"
}
variable "vpc_id" {
  type = string
}

## listener.tf
variable "listener_arn" {
  type = string
}
variable "priority" {
  type = number
}
variable "host_header_values" {
  type = list(string)
  default = []
}
variable "rule_name" {
  type =  string
}