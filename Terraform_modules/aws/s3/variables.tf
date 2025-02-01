variable "bucket_name" {
  type = string
}

variable "block_public_access" {
  type    = bool
  default = true
}

variable "sse_algorithm" {
  default = "AES256"
  type    = string
}

variable "bucket_key_enabled" {
  type    = bool
  default = true
}

variable "versioning" {
  default = "Disabled" #"Enabled"
  type    = string
}