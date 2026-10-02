# Terraform + Proxmox: first config (READ-ONLY)
# Purpose: verify authentication before creating anything.
# Safe to run `terraform plan` any number of times — nothing is created or changed.

terraform {
  required_providers {
    # bpg/proxmox is the actively maintained community provider for Proxmox VE
    # (the original telmate one is unmaintained). "~> 0.113" means: any 0.113.x
    # patch release, but never a new minor version without your say-so.
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.113"
    }
  }
}

provider "proxmox" {
  # Where the Proxmox API lives. No /api2/json suffix — the provider adds it.
  endpoint = "https://192.168.50.65:8006/"

  # Your box uses Proxmox's self-signed TLS certificate, so skip verification.
  # (Production-grade alternative: point a real CA cert at it instead.)
  insecure = true

  # The token is read from the PROXMOX_VE_API_TOKEN environment variable —
  # it never appears in this file, in state, or in git. Format of the value:
  #   terraform@pam!terraform=<secret-shown-once-at-creation>
}

# --- Read-only data sources ---------------------------------------------
# A "data source" asks the provider to *look up* something that already
# exists. It's how Terraform says "I need to know about this" without
# "I want to create/modify this".

# The Proxmox version running on the box (release + full build string).
data "proxmox_version" "pve" {}

# Node configuration (description, name, etc.).
data "proxmox_node_config" "pve" {
  node_name = "pve"
}

# All containers currently in the cluster (empty list for now —
# we haven't created any yet; it becomes useful later as a sanity check).
data "proxmox_virtual_environment_containers" "all" {
  node_name = "pve"
}

# --- Outputs: what `terraform plan` will show you ------------------------
output "proxmox_version" {
  description = "Proxmox VE version as seen by the provider"
  value       = data.proxmox_version.pve
}

output "node_config" {
  description = "Node configuration"
  value       = data.proxmox_node_config.pve
}

output "existing_containers" {
  description = "Containers currently on the node (name + ID)"
  value       = [for c in data.proxmox_virtual_environment_containers.all.containers : { name = c.name, vm_id = c.vm_id }]
}
