resource "proxmox_virtual_environment_vm" "node" {
  name      = var.name
  vm_id     = var.vm_id # Just an indentifier, must be unique
  on_boot   = true      # Ensures the VM runs when the Minipc is booted
  node_name = "pve"
  serial_device {
    device = "socket"
  }
  # Arguments with curly brackets containing nested "Arguments" are called a "Block"
  cpu {
    cores = var.cpu_cores # 2 full cores
  }
  memory {
    dedicated = var.memory_mb # MB unit -> 4GB
    floating  = 0             # Memory Ballooning buffer, 0 = none
  }
  dynamic "disk" {
    for_each = var.import_from != null ? [1] : []
    content {
      import_from  = var.import_from
      datastore_id = "local-lvm"
      size         = 32
      interface    = "scsi0"
    }
  }
  dynamic "clone" {
    for_each = var.clone_from_vm_id != null ? [1] : []
    content {
      vm_id = var.clone_from_vm_id
      full  = true
    }
  }
  operating_system {
    type = "l26"
  }
  network_device {
    bridge = "vmbr0" # Ensuring the bridge from the Minipc is used.
    model  = "virtio"
  }
  initialization {
    dns {
      servers = ["192.168.50.1"] # Router IP address
    }
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = "192.168.100.2" # Minipc bridge IP
      }
    }
    user_account {
      username = "debian"
      keys     = [var.ssh_public_key]
    }
  }
  tags = var.tags # Just labels, no functional behaviour
}

