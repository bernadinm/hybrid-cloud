# Specify the provider and access details
provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

# Runs a local script to return the current user in bash
data "external" "whoami" {
  program = ["scripts/local/whoami.sh"]
}

# Allow overrides of the owner variable or default to whoami.sh
data "template_file" "cluster-name" {
 template = "$${username}-tf$${uuid}"

  vars {
    username = "${format("%.10s", coalesce(var.owner, data.external.whoami.result["owner"]))}"
    uuid     = "${substr(md5(random_id.cluster.id),0,4)}"
  }
}

# Create DCOS Bucket regardless of what exhibitor backend was chosen
resource "aws_s3_bucket" "dcos_bucket" {
  bucket = "${data.template_file.cluster-name.rendered}-bucket"
  acl    = "private"
  force_destroy = "true"

  tags {
   Name = "${data.template_file.cluster-name.rendered}-bucket"
   cluster = "${data.template_file.cluster-name.rendered}"
  }
}

# Provide tested AMI and user from listed region startup commands
  module "aws-tested-oses" {
      source   = "./modules/dcos-tested-aws-oses"
      os       = "${var.os}"
      region   = "${var.aws_region}"
}

# Privdes a unique ID thoughout the livespan of the cluster
resource "random_id" "cluster" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    id = "${coalesce(var.owner, data.external.whoami.result["owner"])}"
  }

  byte_length = 8
}
