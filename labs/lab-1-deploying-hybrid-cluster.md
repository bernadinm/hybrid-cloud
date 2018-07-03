# Multi-Cloud Open DC/OS on AWS with Terraform
# AWS and Azure

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.11.x

## Deploying Multi-Cloud DCOS 

This repository is meant to get the bare minimum of running a multi-cloud DC/OS cluster.

This repo is configured to deploy on AWS and Azure using Cisco CSR 1000V for VPN connection in between.

## Terraform Prerequisites Quick Start

1. Accept the AWS Cisco CSR subscription from the Marketplace by clicking the link below with the same AWS account that will be launchng the terraform scripts:

https://aws.amazon.com/marketplace/pp?sku=9vr24qkp1sccxhwfjvp9y91p1

2.  Accept the Azure Cisco CSR subscription from the marketplace 

3.  Retrieve Sales Mesosphere License Key via OneLogin here: https://mesosphere.onelogin.com/notes/56317

4.  Retrieve Sales Mesosphere Private and Public Key via OneLogin here: https://mesosphere.onelogin.com/notes/41130

5.  Retrieve Mesosphere MAWS Commandline tool for access to AWS: https://github.com/mesosphere/maws/releases

6.  Retrieve Azure CLI tool for access to Azure: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

```bash
mkdir terraform-demo && cd terraform-demo
terraform init -from-module github.com/bernadinm/hybrid-cloud
cp desired_cluster_profile.tfvars.example desired_cluster_profile.tfvars
```

### Configure Mesosphere MAWS 

```bash
# Download maws-darwin binary from https://github.com/mesosphere/maws/releases
chmod +x maws*
sudo mv ~/Downloads/maws* /usr/local/bin/maws
maws login 110465657741_Mesosphere-PowerUser
```

### Configure SSH Private and Public Key for Terraform

Set your ssh agent locally to point to your pem key and public key

```bash
$ ssh-add /path/to/ssh_private_key.pem
```

```bash
$ cat desired_cluster_profile.tfvars | grep ssh_pub_key
ssh_pub_key = "<INSERT_SSH_PUB_KEY>"
```

### Configure Mesosphere License Key in Terraform

Copy your license and place it in the `desired_cluster_profile.tfvars`

```bash
$ cat desired_cluster_profile.tfvars | grep dcos_license_key_contents
dcos_license_key_contents = "<MY_LICENSE_KEY>"
```

### Configure your aws_profile in Terraform

Copy you Mesosphere `maws` profile name and provide it to terraform. For the sales team, it is already known to be `110465657741_Mesosphere-PowerUser` so it will look like this below:

```bash
$ cat desired_cluster_profile.tfvars | grep aws_profile
aws_profile = "110465657741_Mesosphere-PowerUser"
```

### Configure your Azure login for Terraform

```bash
$ az login
```

### Deploy Multi-Cloud via Terraform 

```bash
$ terraform apply -var-file desired_cluster_profile.tfvars
```

Here is an output of a successful deployment:

```
Apply complete! Resources: 114 added, 0 changed, 0 destroyed.

Outputs:

AWS Cisco CSR VPN Router Public IP Address = 18.206.133.140
Azure Cisco CSR VPN Router Public IP Address = 40.118.230.34
Bootstrap Host Public IP = mbernadin-tf80cc-bootstrap.westus.cloudapp.azure.com
Bootstrap Public IP Address = 34.229.179.46
Master ELB Public IP = mbernadin-tf80cc-pub-mas-elb-1841202780.us-east-1.elb.amazonaws.com
Master Public IPs = [
    52.204.155.230
]
Private Agent Public IPs = [
    mbernadin-tf80cc-agent-1.westus.cloudapp.azure.com
]
Public Agent ELB Address = mbernadin-tf80cc-pub-agt-elb-1182904022.us-east-1.elb.amazonaws.com
Public Agent ELB Public IP = public-agent-mbernadin-tf80cc.westus.cloudapp.azure.com
Public Agent Public IPs = [
    mbernadin-tf80cc-public-agent-1.westus.cloudapp.azure.com
]
ssh_user = core
```

### Destroy Cluster

For the purpose of this lab we will be keeping our cluster up and running, but if you needed to destroy your cluster for any reason now, here is the command: 

```bash
terraform destroy -var-file desired_cluster_profile.tfvars
```

Note: No major enhancements should be expected with this repo. It is meant for demo and testing purposes only.

### Navigation

1. LAB1 - Deploying AWS Using Terraform (current)
2. [LAB2 - Bursting from AWS to Azure](./lab-2-bursting-from-aws-to-azure.md)
3. [LAB3 - Deploying and Migrating Stateless App from AWS to Azure](./lab-3-deploying-and-migrating-stateless-app.md)
4. [LAB4 - Deploying Cassandra Multi DataCenter](./lab-4-deploying-cassandra-multi-dc-cluster.md)

[Return to Main Page](../README.md)
