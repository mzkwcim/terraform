variable "vm_ip" {
  description = "IP address of the virtual machine"
  type        = string
  default     = "192.168.56.106"
}

variable "vm_username" {
  description = "Username for VM authentication"
  type        = string
  default     = "Administrator"
}

variable "vm_password" {
  description = "Password for VM authentication"
  type        = string
  default     = "zaq1@WSX"
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "DC1"
}

variable "ova_path" {
  description = "Path to the OVA file"
  type        = string
  default     = "E:\\Windows Server 2022_sysprep.ova"
}
