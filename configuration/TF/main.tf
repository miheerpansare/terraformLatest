variable "vm_name" {
  type        = string
  description = "VM Name"
}
variable "domain" {
  type        = string
  description = "Domain"
}

provider "vsphere" {

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}
data "vsphere_datastore" "datastore" {
  name          = "Datastore-10.206.241.150"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VMNetwork-PortGroup"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "host" {
  name = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "Cluster/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}



resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus = 1
  memory   = 512
  guest_id = "other3xLinux64Guest"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0	
  host_system_id = data.vsphere_host.host.id	
  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }
  ovf_deploy {
    // Url to remote ovf/ova file
    remote_ovf_url = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.ova"
  }

  disk {
    label = "disk0"
    size  = 10
  }
}