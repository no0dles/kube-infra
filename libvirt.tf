provider "libvirt" {
  uri = "qemu:///system"
}

variable "hosts" {
  default = 1
}

variable "kube_version" {
  default = "v1.17.0"
}

variable "hostname_format" {
  type    = string
  default = "coreos%02d"
}

resource "libvirt_volume" "coreos-disk" {
  name             = "${format(var.hostname_format, count.index + 1)}.qcow2"
  count            = var.hosts
  source           = "/var/lib/libvirt/images/container-linux/coreos_production_qemu_image.img"
  pool             = "default"
  format           = "qcow2"
}

resource "libvirt_ignition" "ignition" {
  name    = "${format(var.hostname_format, count.index + 1)}-ignition"
  pool    = "default"
  count   = var.hosts
  content = element(data.ignition_config.startup.*.rendered, count.index)
}

resource "libvirt_domain" "coreos-machine" {
  count  = var.hosts
  name   = format(var.hostname_format, count.index + 1)
  vcpu   = "6"
  memory = "24576"

  coreos_ignition = element(libvirt_ignition.ignition.*.id, count.index)

  disk {
    volume_id = element(libvirt_volume.coreos-disk.*.id, count.index)
  }

  graphics {
    listen_type = "address"
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }
}

output "ipv4" {
  value = libvirt_domain.coreos-machine.*.network_interface.0.addresses
}

terraform {
  required_version = ">= 0.12"
}