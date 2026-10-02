variable "name" {
  description = "Name of the VM in proxmox"
  type        = string
}

variable "vm_id" {
  description = "Unique vm identifier"
  type        = number
}

variable "ip_address" {
  description = "IPv4 address"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "import_from" {
  description = "Datastore file ID to import from as the root disk"
  type        = string
  default     = null
}

variable "clone_from_vm_id" {
  description = "VM ID to clone from (saves redownloading img)"
  type        = number
  default     = null
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 4096
}

variable "tags" {
  type    = list(string)
  default = ["k3s", "terraform"]
}