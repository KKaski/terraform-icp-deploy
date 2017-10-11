# Terraform ICP Nodes Provision Module
This terraform module can be used to create the worker and master nodes for ICP
This module is using 

deploy IBM Cloud Private on any supported infrastructure vendor.
Currently tested with Ubuntu 16.06 on SoftLayer VMs, deploying ICP 1.2.0 and 2.1.0-beta-1 Community Editions.

### Pre-requisites

If the default SSH user is not the root user, the default user must have password-less sudo access.


## Inputs

| variable  |  default  | required |  description    |
|-----------|-----------|---------|--------|
|  cluster_size   |      |  Yes  |   Define total clustersize. Workaround for terraform issue #10857.                | 



## Usage example

```hcl
Generate your ssh keys
ssh-keygen -f ssh_key -P ""
set the parameters to the terraform.tfvars

Refresh the modules
terraform init
terraform get
terraform apply -var-file terraform.tfvars
```



