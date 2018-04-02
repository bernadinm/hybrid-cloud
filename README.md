# Multi-Cloud Open DC/OS on AWS with Terraform
# AWS and Azure

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.10.x

## Deploying Multi-Cloud DCOS 

This repository is meant to get the bare minimum of running a multi-region DC/OS cluster. It is not as modifiable as dcos/terraform-dcos so please keep this in mind. 

This repo is configured to deploy on us-east-1 and us-west-2 with an AWS VPC Peering connection across regions.


## Terraform Quick Start

```bash
mkdir terraform-demo && cd terraform-demo
terraform init -from-module github.com/bernadinm/hybrid-cloud
terraform apply -var-file desired_cluster_profile.tfvars
```

### High Level Overview of Architecture

* a VPC Peering connection that connects us-east-1 and us-west-2 
* Main DC/OS cluster lives on us-east-1
* Bursting Node lives in us-west-2

### Adding or Remving Remote Nodes or Default Region Nodes

Change the number of remote nodes in the desired cluster profile.

```bash 
$ cat desired_cluster_profile.tfvars
dcos_version = "1.11.0"
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
num_of_private_agent_group_1 = "3"
num_of_private_agent_group_2 = "3"
num_of_private_agent_group_3 = "3"
# ---- Public Agents Zone / Instance
aws_group_1_public_agent_az = "a"
aws_group_2_public_agent_az = "c"
aws_group_3_public_agent_az = "c"
num_of_public_agent_group_1 = "0"
num_of_public_agent_group_2 = "0"
num_of_public_agent_group_3 = "1"
# ----- Remote Region Below
num_of_azure_private_agents = "3"
# ----- DCOS Config Below
dcos_security = "permissive"
dcos_cluster_name = "Hybrid-Cloud"
aws_profile = "SE"
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
