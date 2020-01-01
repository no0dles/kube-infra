data "ignition_config" "startup" {
  users = [
    data.ignition_user.core.rendered,
  ]

  files = [
    element(data.ignition_file.hostname.*.rendered, count.index),
    data.ignition_file.kubectl.rendered,
    data.ignition_file.kubeadm.rendered,
    data.ignition_file.kubeadm-config.rendered,
    data.ignition_file.kubeadm-init.rendered,
    data.ignition_file.kubelet.rendered,
    data.ignition_file.kubelet-conf.rendered,
    data.ignition_file.environment.rendered,
  ]

  systemd = [
   "${data.ignition_systemd_unit.kubelet.rendered}",
   "${data.ignition_systemd_unit.docker.rendered}"
  ]

  count = var.hosts
}

data "ignition_file" "kubectl" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/opt/bin/kubectl"
  mode       = 493 # decimal 0755

  source {
    source = format("https://storage.googleapis.com/kubernetes-release/release/%s/bin/linux/amd64/kubectl", var.kube_version)
  }
}

data "ignition_file" "kubeadm" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/opt/bin/kubeadm"
  mode       = 493 # decimal 0755

  source {
    source = format("https://storage.googleapis.com/kubernetes-release/release/%s/bin/linux/amd64/kubeadm", var.kube_version)
  }
}

data "ignition_file" "kubelet" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/opt/bin/kubelet"
  mode       = 493 # decimal 0755

  source {
    source = format("https://storage.googleapis.com/kubernetes-release/release/%s/bin/linux/amd64/kubelet", var.kube_version)
  }
}

data "ignition_file" "kubelet-conf" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
  mode       = 420 # decimal 0644

  content { content = "${file("${path.module}/systemd/10-kubeadm.conf")}" }
}


data "ignition_file" "kubeadm-config" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/home/core/config.yaml"
  mode       = 420 # decimal 0644

  content { content = "${file("${path.module}/config.yaml")}" }
}

data "ignition_file" "kubeadm-init" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/home/core/init.sh"
  mode       = 493 # decimal 0644

  content { content = "${file("${path.module}/init.sh")}" }
}

data "ignition_file" "hostname" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/etc/hostname"
  mode       = 420 # decimal 0644

  content {
    content = format(var.hostname_format, count.index + 1)
  }

  count = var.hosts
}

data "ignition_file" "environment" {
  filesystem = "root" # default `ROOT` filesystem
  path       = "/etc/environment"
  mode       = 420 # decimal 0644

  content {
    content = "PATH=$PATH:/opt/bin"
  }
}



data "ignition_user" "core" {
  name = "core"

  #Example password: foobar
  password_hash = "$5$XMoeOXG6$8WZoUCLhh8L/KYhsJN2pIRb3asZ2Xos3rJla.FA1TI7"
  #ssh_authorized_keys = "${list()}"
}

data "ignition_systemd_unit" "docker" {
 name = "docker.service"
 enabled = true
}

## Relevant for the QEMU Guest Agent example
data "ignition_systemd_unit" "kubelet" {
 name = "kubelet.service"
 enabled = true
 content = "${file("${path.module}/systemd/kubelet.service")}"
}