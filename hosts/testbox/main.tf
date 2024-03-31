# Create a VM to test nixos installation using libvirt to first test config before switching to nixos

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

variable "nixos_version" {
  type     = string
  nullable = false
  default  = "23.11"
}

provider "libvirt" {
  uri = "qemu:///session"
}

resource "libvirt_domain" "nixos_testbox" {
  name     = "nixos_testbox"
  vcpu     = 8
  memory   = 4096                                  #MiB
  firmware = "/usr/share/edk2/x64/OVMF_CODE.4m.fd" # UEFI (might be somewhere elsse depending on distro)
  lifecycle {
    ignore_changes = [nvram] # managed by libvirt
  }

  network_interface {
    network_name = libvirt_network.nixos_testbox_network.name # virsh net-list --all
  }

  disk {
    volume_id = libvirt_volume.nixos_testbox_image.id
  }
  disk {
    volume_id = libvirt_volume.nixos_testbox_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  filesystem {
    # share the repo with the VM
    # had to set following entries in /etc/libvirt/qemu.conf to make it work:
    #   user = "root"
    #   group = "root"
    #   dynamic_ownership = 0
    # 
    # Better not do this if you have other VMs running on the same machine.
    #
    # Inside the VM mount with:
    # sudo mount -t 9p -o trans=virtio,version=9p2000.L,rw repo /some/dir
    source   = "${abspath(path.module)}/../.."
    target   = "repo"
    readonly = false
  }

}

resource "libvirt_pool" "nixos_testbox_pool" {
  name = "nixos_testbox"
  type = "dir"
  path = "/var/lib/libvirt/images/nixos_testbox"
}

resource "libvirt_volume" "nixos_testbox_image" {
  name   = "latest-nixos-minimal-x86_64-linux.iso"
  pool   = libvirt_pool.nixos_testbox_pool.name
  source = "https://channels.nixos.org/nixos-${var.nixos_version}/latest-nixos-minimal-x86_64-linux.iso"
  #source = "./latest-nixos-minimal-x86_64-linux.iso"
}

resource "libvirt_volume" "nixos_testbox_disk" {
  name = "nixos_testbox_disk"
  pool = libvirt_pool.nixos_testbox_pool.name
  size = 100000000000 # 100 GB
}

resource "libvirt_network" "nixos_testbox_network" {
  name      = "nixos_testbox"
  mode      = "nat"
  addresses = ["192.168.99.0/24"]
  dns {
    enabled = true
  }
}

output "ip" {
  value = libvirt_domain.nixos_testbox.network_interface.0.addresses
}
