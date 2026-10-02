terraform {
  required_providers {
    # Proxmox is the only external provider used here, registry details can be found on terraform's registry page for providers.
    proxmox = {
        source = "bpg/proxmox"
        version = "~> 0.113"
    }

    # Adding in two terraform providers to nail down the versions.
    local = {
        source = "registry.terraform.io/hashicorp/local"
        version = "~> 2.9" 
    }
    tls   = {
        source = "registry.terraform.io/hashicorp/tls"
        version = "~> 4.4"
    }
  }
}

provider "proxmox" {
    endpoint = "https://192.168.50.65:8006/"
    insecure = true
}

# Data block checks which datastores exist on the target, consumed by a precondition in vm.tf in the "proxmox_virtual_environment_vm" resource
data "proxmox_datastores" "pve" {
    node_name = "pve"
}
