variable "stack_type" {
  description = "The type of application stack (e.g., dotnet, python, nodejs)"
  type        = string
  default     = "dotnet"
}

variable "dotnet_version" {
  description = "The version of the .NET stack"
  type        = string
  default     = "v7.0"
}

variable "node_version" {
  description = "The version of the Node.js stack"
  type        = string
  default     = "~18"
}

variable "python_version" {
  description = "The version of the Python stack"
  type        = string
  default     = "3.12"
}

variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "location" {
}

variable "resource_group_name" {
}

variable "subnet_id" {
}

variable "block_public_access" {
  type    = bool
  default = false
}

variable "app_gw_subnet_id" {
  type = string
}

variable "az_devops_agent_subnet_id" {
  type = string
}

variable "app_service_plan_id" {
}

variable "app_name" {

}

variable "cors" {
  type    = list(string)
  default = []
}