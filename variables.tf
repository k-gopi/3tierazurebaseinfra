variable "rg_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "myResourceGroup"
}

variable "location" {
  description = "The Azure Region"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "myVNet"
}

variable "subnet_web_name" {
  description = "The name of the Web Subnet"
  type        = string
  default     = "webSubnet"
}

variable "subnet_app_name" {
  description = "The name of the App Subnet"
  type        = string
  default     = "appSubnet"
}

variable "subnet_db_name" {
  description = "The name of the Database Subnet"
  type        = string
  default     = "dbSubnet"
}

variable "subnet_lb_name" {
  description = "The name of the Load Balancer Subnet"
  type        = string
  default     = "lbSubnet"
}
variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
}
variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}
