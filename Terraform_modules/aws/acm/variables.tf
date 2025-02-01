variable "domains" {
  type = set(string)
  default = []
}
variable "dns_zone_id" {
  type = string
}