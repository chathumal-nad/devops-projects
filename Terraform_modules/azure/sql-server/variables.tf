variable "max_size_gb" {
  default = 2
}

variable "min_capacity" {
  default = 0.5
}

variable "auto_pause_delay_in_minutes" {
  default = 60
}

variable "prefix" {
  type = string
}

variable "suffix" {

}

variable "location" {

}

variable "db_admin" {

}

variable "resource_group_name" {
}

variable "subnet_id" {

}

variable "admin_login_username" {
  default = "xxxxxx"
}

variable "db_sku" {
  default = "GP_S_Gen5_1"
}