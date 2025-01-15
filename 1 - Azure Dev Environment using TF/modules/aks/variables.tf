variable "cluster-name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource-group-name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vn-name" {
  type = string
}

variable "vn-subnet-prefix" {
  type = set(string)
}