variable "virtual-machine-names" {
  type = set(string)
}

variable "location" {
  type = string
}

variable "resource-group-name" {
  type = string
}

variable "subnet-id" {
  type = string
}

variable "availability-set-id" {
  type    = string
  default = null
}

variable "need-additional-disks" {
  type = bool
}

variable "script-name" {
  type    = string
  default = "script-default.sh"
}

variable "need-public-ip" {
  type    = bool
  default = true
}

variable "vm-size" {
  type    = string
  default = "Standard_B1ls"
}
# B1ls(4) < B1s(8) < B1ms(16) < B2s(32)