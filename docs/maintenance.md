## Maintenance

### Adding or Removing Remote Nodes or Default Region Nodes

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
num_of_private_agent_group_1 = "3"
num_of_private_agent_group_2 = "3"
num_of_private_agent_group_3 = "3"
# ---- Public Agents Zone / Instance
aws_group_1_public_agent_az = "a"
aws_group_2_public_agent_az = "b"
aws_group_3_public_agent_az = "c"
num_of_public_agent_group_1 = "0"
num_of_public_agent_group_2 = "0"
num_of_public_agent_group_3 = "1"
# ----- Remote Region Below
num_of_azure_private_agents = "5"
num_of_azure_public_agents  = "1"
# ----- DCOS Config Below
dcos_cluster_name = "Hybrid-Cloud"
aws_profile = "110465657741_Mesosphere-PowerUser"
dcos_license_key_contents = "<INSERT_LICENSE_HERE>"
ssh_pub_key = "<INSERT_SSH_PUB_KEY>"
```

```bash
terraform apply -var-file desired_cluster_profile.tfvars
```
