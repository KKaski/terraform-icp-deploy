##############################################################################
# Variables for creating the workers
##############################################################################
variable bxapikey {
  description = "Your Bluemix API Key."
}
variable slusername {
  description = "Your Softlayer username."
}
variable slapikey {
  description = "Your Softlayer API Key."
}
variable datacenter {
  description = "The datacenter to create resources in."
}
variable public_key {
  description = "Your public SSH key."
}

variable private_key {
  description = "Your private SSH key."
}

variable key_label {
  description = "A label for the SSH key that gets created."
}
variable key_note {
  description = "A note for the SSH key that gets created."
}

variable cluster_size {
  description = "Number of worker nodes to be added"
}

variable  "icp-version" {
  description = "Version of ICP to provision. For example 1.2.0, 1.2.0-ee, 2.1.0-beta-1 or icp-inception:2.1.0-beta-3"
}

variable  "vlan" {
  description = "vlan ID for the nodes"
}