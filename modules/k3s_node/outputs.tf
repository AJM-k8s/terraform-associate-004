output "vm_id" {
  description = "VM ID as created in proxmox"
  value       = proxmox_virtual_environment_vm.node.id
}

output "name" {
  value = proxmox_virtual_environment_vm.node.name
}