variable "asp-name" {

}
variable "resource_group_name" {

}
variable "location" {

}
variable "os_type" {
  default = "Windows"
}
variable "sku_name" {
  default = "B1"
}
variable "worker_count" {
  type    = number
  default = 1
}
variable "zone_balancing_enabled" {
  type    = bool
  default = false
}