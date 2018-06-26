# Multi-Cloud Open DC/OS on AWS with Terraform
# AWS and Azure

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.11.x

## Deploying Multi-Cloud DCOS 

This repository is meant to get the bare minimum of running a multi-cloud DC/OS cluster.

This repo is configured to deploy on AWS and Azure using Cisco CSR 1000V for VPN connection in between.


### High Level Overview of Architecture

* Creates an AWS cluster with masters and agents
* Creates an Azure node with public and private agents
* Main DC/OS cluster lives on AWS
* Bursting Node lives in Azure



## Terraform Prerequisites Quick Start

1. Accept the AWS Cisco CSR subscription from the Marketplace by clicking the link below with the same AWS account that will be launchng the terraform scripts:

https://aws.amazon.com/marketplace/pp?sku=9vr24qkp1sccxhwfjvp9y91p1

2.  Accept the Azure Cisco CSR subscription from the marketplace 

3.  Retrieve Sales Mesosphere License Key via OneLogin here: https://mesosphere.onelogin.com/notes/51818

4.  Retrieve Sales Mesosphere PEM Key via OneLogin here: https://mesosphere.onelogin.com/notes/41130

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
### Configure Mesosphere License Key in Terraform

Copy your license and place it in the `desired_cluster_profile.tfvars`

```bash
$ cat desired_cluster_profile.tfvars | grep dcos_license_key_contents
dcos_license_key_contents = "<MY_LICENSE_KEY>"
```

### Configure your aws_profile in Terraform

Copy you Mesosphere `maws` profile name and provide it to terraform. For the sales team, it is already know to be `110465657741_Mesosphere-PowerUser` so it will look like this below:

```bash
$ cat desired_cluster_profile.tfvars | grep aws_profile
aws_profile = "110465657741_Mesosphere-PowerUser"
```



### Adding or Remving Remote Nodes or Default Region Nodes

Change the number of remote nodes in the desired cluster profile.

```bash 
dcos_version = "1.11.2"
num_of_masters = "1"
aws_region = "us-east-1"
aws_master_instance_type = "m4.xlarge"
aws_agent_instance_type = "m4.xlarge"
aws_public_agent_instance_type = "m4.xlarge"
aws_private_agent_instance_type = "m4.xlarge"
aws_bootstrap_instance_type = "m4.xlarge"
# ---- Private Agents Zone / Instance
aws_group_1_private_agent_az = "a"
aws_group_2_private_agent_az = "b"
aws_group_3_private_agent_az = "c"
num_of_private_agent_group_1 = "1"
num_of_private_agent_group_2 = "0"
num_of_private_agent_group_3 = "0"
# ---- Public Agents Zone / Instance
aws_group_1_public_agent_az = "a"
aws_group_2_public_agent_az = "b"
aws_group_3_public_agent_az = "c"
num_of_public_agent_group_1 = "0"
num_of_public_agent_group_2 = "0"
num_of_public_agent_group_3 = "0"
# ----- Remote Region Below
num_of_azure_private_agents = "1"
num_of_azure_public_agents  = "0"
# ----- DCOS Config Below
dcos_cluster_name = "Hybrid-Cloud"
aws_profile = "273854932432_Mesosphere-PowerUser"
dcos_license_key_contents = "<INSERT_LICENSE_HERE>"
```

```bash
terraform apply -var-file desired_cluster_profile.tfvars
```

### Destroy Cluster


1. Destroy terraform with this command below.
```bash
terraform destroy -var-file desired_cluster_profile.tfvars
```

Note: No major enhancements should be expected with this repo. It is meant for demo and testing purposes only.
