resource "proxmox_download_file" "debian_bookworm" {
# Simple variable names like these are called "Arguments"
	content_type = "import" # Must be an acceptable type in /etc/pve/storage.cfg
	datastore_id = "local" # Where the file is downloaded to, defined in /etc/pve/storage.cfg opn the Minipc
	node_name = "pve" # Node name comes from Proxmox
	url = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"
	file_name = "debian-12-genericcloud-amd64.raw" # Must match the file in the URL above
}

resource "proxmox_virtual_environment_vm" "k3s_server" {
	name = "k3s-server"
	vm_id = 9001 # Just an indentifier, must be unique
	on_boot = true # Ensures the VM runs when the Minipc is booted
	node_name = "pve"
	
# Arguments with curly brackets containing nested "Arguments" are called a "Block"
	serial_device {
		device = "socket"
	}
	cpu {
		cores = 2 # 2 full cores
	}
	memory {
		dedicated = 4096 # MB unit -> 4GB
		floating = 0 # Memory Ballooning buffer, 0 = none
	}
	disk {
		import_from = proxmox_download_file.debian_bookworm.id
		datastore_id = "local-lvm"
		size = 32 # GB unit
		interface = "scsi0"
	}
	operating_system {
		type = "l26"
	}
	network_device {
		bridge = "vmbr0" # Ensuring the bridge from the Minipc is used.
		model = "virtio"
	}
	initialization {
		dns {
			servers = ["192.168.50.1"] # Router IP address
		}
		ip_config {
			ipv4 {
				address = "192.168.100.10/24"
				gateway = "192.168.100.2" # Minipc bridge IP
			}
		}
		user_account {
			username = "debian"
			keys = [tls_private_key.k3s_server.public_key_openssh]
		}
	}


	tags = ["k3s", "terraform"] # Just labels, no functional behaviour
}

resource "tls_private_key" "k3s_server"{
	algorithm = "ED25519"
}

resource "local_file" "k3s_server_key" {
	content = tls_private_key.k3s_server.private_key_pem
	filename = pathexpand("~/.ssh/k3s-server")
	file_permission = "0600"
}
