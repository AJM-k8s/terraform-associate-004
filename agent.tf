resource "proxmox_virtual_environment_vm" "agent" {
	name = "agent"
	vm_id = 9002 # Just an indentifier, must be unique
	on_boot = true # Ensures the VM runs when the Minipc is booted
	node_name = "pve"

# Arguments with curly brackets containing nested "Arguments" are called a "Block"
	cpu {
		cores = 2 # 2 full cores
	}
	memory {
		dedicated = 4096 # MB unit -> 4GB
		floating = 0 # Memory Ballooning buffer, 0 = none
	}
    clone {
        vm_id = proxmox_virtual_environment_vm.k3s_server.id
        full  = true # full copy; false = linked clone (dies with source)
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
				address = "192.168.100.11/24"
				gateway = "192.168.100.2" # Minipc bridge IP
			}
		}
		user_account {
			username = "debian"
			keys = [tls_private_key.agent.public_key_openssh]
		}
	}


	tags = ["agent", "terraform"] # Just labels, no functional behaviour
}

resource "tls_private_key" "agent"{
	algorithm = "ED25519"
}

resource "local_file" "agent_key" {
	content = tls_private_key.agent.private_key_pem
	filename = pathexpand("~/.ssh/agent")
	file_permission = "0600"
}
