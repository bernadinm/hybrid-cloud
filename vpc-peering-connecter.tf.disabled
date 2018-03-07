## Declare the data source
#data "aws_vpc_peering_connection" "default" {
#  vpc_id          = "${aws_vpc.default.id}"
#  peer_vpc_id     = "${aws_vpc.bursted_region.id}"
#  peer_region     = "${var.aws_remote_region}"
#  depends_on = ["aws_vpc_peering_connection.peering"]
#}

# Create a route
resource "aws_route" "r" {
  route_table_id            = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block    = "${aws_vpc.bursted_region.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

## Create a route
resource "aws_route" "r-bursted" {
  provider = "aws.bursted-vpc"
  route_table_id            = "${aws_vpc.bursted_region.main_route_table_id}"
  destination_cidr_block    = "${aws_vpc.default.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

resource "aws_vpc_peering_connection" "peering" {
  vpc_id          = "${aws_vpc.default.id}"
  peer_vpc_id     = "${aws_vpc.bursted_region.id}"
  peer_region     = "${var.aws_remote_region}"

  tags {
    Name = "VPC Peering between default and bursting"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "aws.bursted-vpc"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
  auto_accept               = true

  tags {
    Side = "Accepter"
  }
}
