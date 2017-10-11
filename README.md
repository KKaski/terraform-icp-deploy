# Terraform ICP Nodes Provision Module
This terraform module can be used to deploy IBM Cloud Private (ICP) to IBM Cloud
This terraform script is using a terraform module https://github.com/ibm-cloud-architecture/terraform-module-icp-deploy
which will tae care of the actual ICP deplouyment where as this script takes care of provisioning of the required servers
and prereqs of these servers.

This deploys IBM Cloud Private on IBM Cloud Infrastructure.
Currently tested with Ubuntu 16.06 on SoftLayer VMs, deploying ICP 1.2.0 and 2.1.0-beta-3 Community Editions.

### Pre-requisites
If the default SSH user is not the root user, the default user must have password-less sudo access.
Ansible needs to be installed and configured

### Current issues
Dependency to ansible

## Inputs

| variable  |  default  | required |  description    |
|-----------|-----------|---------|--------|
|  cluster_size   |      |  Yes  |   Define total clustersize. Workaround for terraform issue #10857.                | 
|  icp-version   |      |  Yes  |   Define ICP version to use.                | 



## Usage example

Generate your ssh keys
ssh-keygen -f ssh_key -P ""
set the parameters to the terraform.tfvars including the public key you just created

Refresh the modules
terraform init
terraform get
terraform apply -var-file terraform.tfvars

Define te requested parameters. When the provisioning is completed the 
URL and username/password is replayed in the output

module.icpprovision.null_resource.icp-boot (remote-exec): UI URL is https://xx.xx.xx.xx:8443 , default username/password is admin/admin



