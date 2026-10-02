terraform {
  required_providers {
    # Proxmox is the only external provider used here, registry details can be found on terraform's registry page for providers.
    proxmox = {
      source  = "registry.terraform.io/bpg/proxmox"
      version = "~> 0.113"
    }

    # Adding in two terraform providers to nail down the versions.
    local = {
      source  = "registry.terraform.io/hashicorp/local"
      version = "~> 2.9"
    }
    tls = {
      source  = "registry.terraform.io/hashicorp/tls"
      version = "~> 4.4"
    }
  }
}