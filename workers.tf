##############################################################################
# Require terraform 0.9.3 or greater
##############################################################################
terraform {
  required_version = ">= 0.9.3"
}
##############################################################################
# IBM Cloud Provider
##############################################################################
# See the README for details on ways to supply these values
provider "ibm" {
  bluemix_api_key = "${var.bxapikey}"
  softlayer_username = "${var.slusername}"
  softlayer_api_key = "${var.slapikey}"
}


##############################################################################
# IBM SSH Key: For connecting to VMs
##############################################################################
resource "ibm_compute_ssh_key" "public_key" {
  label = "${var.key_label}"
  notes = "${var.key_note}"
  # Public key, so this is completely safe
  public_key = "${var.public_key}"
}

##############################################################################
# Create Master Node with the SSH keys
##############################################################################
resource "ibm_compute_vm_instance" "master_node" {
  count                = 1
  hostname             = "master-${count.index+1}"
  domain               = "test.local"
  ssh_key_ids          = ["${ibm_compute_ssh_key.public_key.id}"]
  os_reference_code    = "UBUNTU_16_64"
  datacenter           = "${var.datacenter}"
  network_speed        = 1000
  cores                = 2
  memory               = 8192
  hourly_billing       = true
  private_network_only = false
  private_vlan_id      = "${var.vlan}"
  local_disk           = true
  hourly_billing       = true
  tags                 = ["ICP","Master"]
  ssh_key_ids          = ["${ibm_compute_ssh_key.public_key.id}"]

 provisioner "remote-exec" {
      inline = [
      "apt-get update && apt-get -y upgrade",
      "apt-get -y install python",
      "apt-get -y install python-pip",
      "pip install --upgrade pip",
      "apt-get install dnsmasq",
       "apt-get install vim"
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = "${file("${var.private_key}")}"
  }
  }
}

##############################################################################
# Create Worker Nodes with the SSH keys
##############################################################################
resource "ibm_compute_vm_instance" "worker_node" {
  count                = "${var.cluster_size}"
  hostname             = "worker-${count.index+1}"
  domain               = "test.local"
  ssh_key_ids          = ["${ibm_compute_ssh_key.public_key.id}"]
  os_reference_code    = "UBUNTU_16_64"
  datacenter           = "${var.datacenter}"
  network_speed        = 1000
  cores                = 2
  memory               = 8192
  hourly_billing       = true
  private_network_only = false
  private_vlan_id      = "${var.vlan}"
  local_disk           = true
  hourly_billing       = true
  tags                 = ["ICP","Worker"]
  ssh_key_ids          = ["${ibm_compute_ssh_key.public_key.id}"]

   provisioner "remote-exec" {
      inline = [
      "apt-get update && apt-get -y upgrade",
      "apt-get -y install python",
      "apt-get -y install python-pip",
      "pip install --upgrade pip",
      "apt-get -y install docker.io",
      "apt-get install dnsmasq",
      "apt-get install vim"
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = "${file("${var.private_key}")}"
  }
  }
 
}

###############################################
# Prepare master and worksers
############################################### 
resource "null_resource" "hosts" {
  depends_on = ["ibm_compute_vm_instance.master_node","ibm_compute_vm_instance.worker_node"]

  provisioner "local-exec" {
  command = "ssh-add ssh_key;ansible-playbook -i hosts ./playbooks/prepare_sl_vms.yml -u root"
  }
}

module "icpprovision" {
    #source = "github.com/ibm-cloud-architecture/terraform-module-icp-deploy"
    source = "github.com/KKaski/terraform-module-icp-deploy.git"

    icp-master = ["${ibm_compute_vm_instance.master_node.ipv4_address}"]
    icp-worker = ["${ibm_compute_vm_instance.worker_node.*.ipv4_address}"]
    icp-proxy = ["${ibm_compute_vm_instance.master_node.ipv4_address}"]
    
    enterprise-edition = false
    icp-version = "${var.icp-version}"
    #icp-version = "1.2.0"

    /* Workaround for terraform issue #10857
     When this is fixed, we can work this out autmatically */
    cluster_size="${null_resource.hosts}"
    cluster_size="${var.cluster_size}"
    #cluster_size  = "${var.master["nodes"] + var.worker["nodes"] + var.proxy["nodes"]}"

    icp_configuration = {
      "network_cidr"              = "192.168.0.0/16"
      "service_cluster_ip_range"  = "192.168.0.1/24"
    }

    generate_key = false
    
    icp_priv_keyfile = "ssh_key"
    icp_pub_keyfile = "ssh_key.pub"
    ssh_user  = "root"
    ssh_key   = "ssh_key"
    
} 

##############################################################################
# Outputs
##############################################################################
output "ssh_key_id" {
  value = "${ibm_compute_ssh_key.public_key.id}"
}

output "master_node_id" {
  value = ["${ibm_compute_vm_instance.master_node.*.id}"]
  }

output "master_node_ip_addresses" {
  value = ["${ibm_compute_vm_instance.master_node.*.ipv4_address}"]
  }

  output "worker_node_id" {
  value = ["${ibm_compute_vm_instance.worker_node.*.id}"]
  }

output "worker_node_ip_addresses" {
  value = ["${ibm_compute_vm_instance.worker_node.*.ipv4_address}"]
  }


