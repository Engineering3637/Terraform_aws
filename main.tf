provider "aws" {
  region = "${var.my_region}"
}

resource "aws_vpc" "group1_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags ={
    Name = "${var.name}-vpc"
  }
}
