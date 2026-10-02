# Node SSH keypairs for each node.
resource "tls_private_key" "k3s_server" {
  algorithm = "ED25519"
}

resource "local_file" "k3s_server_key" {
  content         = tls_private_key.k3s_server.private_key_pem
  filename        = pathexpand("~/.ssh/k3s-server")
  file_permission = "0600"
}

resource "tls_private_key" "agent" {
  algorithm = "ED25519"
}

resource "local_file" "agent_key" {
  content         = tls_private_key.agent.private_key_pem
  filename        = pathexpand("~/.ssh/agent")
  file_permission = "0600"
}

# Image download resource.
resource "proxmox_download_file" "debian_bookworm" {
  # Simple variable names like these are called "Arguments"
  content_type = "import" # Must be an acceptable type in /etc/pve/storage.cfg
  datastore_id = "local"  # Where the file is downloaded to, defined in /etc/pve/storage.cfg opn the Minipc
  node_name    = "pve"    # Node name comes from Proxmox
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"
  file_name    = "debian-12-genericcloud-amd64.raw" # Must match the file in the URL above
}

locals {
  agents = {
    agent = {
      name       = "agent"
      vm_id      = 9002
      ip_address = "192.168.100.11/24"
      tags       = ["agent", "terraform"]
    }
  }

  node_keys = {
    server = tls_private_key.k3s_server.public_key_openssh
    agent  = tls_private_key.agent.public_key_openssh
  }
}

module "k3s_server" {
  source         = "./modules/k3s_node"
  name           = "k3s-server"
  vm_id          = 9001
  ip_address     = "192.168.100.10/24"
  tags           = ["k3s", "terraform"]
  ssh_public_key = tls_private_key.k3s_server.public_key_openssh
  import_from    = proxmox_download_file.debian_bookworm.id
}

module "k3s_agent" {
  source           = "./modules/k3s_node"
  for_each         = local.agents
  depends_on       = [module.k3s_server] # all agents wait for the server to exist
  name             = each.value.name
  vm_id            = each.value.vm_id
  ip_address       = each.value.ip_address
  tags             = each.value.tags
  ssh_public_key   = local.node_keys[each.key]
  clone_from_vm_id = module.k3s_server.vm_id # cross-call reference: legal
}

moved {
  from = proxmox_virtual_environment_vm.k3s_server
  to   = module.k3s_server.proxmox_virtual_environment_vm.node
}
moved {
  from = proxmox_virtual_environment_vm.agent
  to   = module.k3s_agent["agent"].proxmox_virtual_environment_vm.node
}