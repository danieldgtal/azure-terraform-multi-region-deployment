variable "student_id" {
  description = "student id"
  type = string
}

# Region variables
variable "region1" {
  type        = string  
  description = "Details for Region 1 resource group"
  default = "westus"
}

variable "region2" {
  type        = string 
  description = "Details for Region 2 resource group"
  default = "westeurope"
}

variable "region3" {
  type        = string  
  description = "Details for Region 3 resource group"
  default = "eastus"
}

variable "vm_size" {
  type = string
  description = "Selected VM Size"
  default = "Standard_B2s"
}

variable "admin_username" {
  type = string
  description = "admin username"
  default = "Student"
}

variable "admin_password" {
  type = string
  description = "admin password"
  default = "P@55w0rd!001"
}