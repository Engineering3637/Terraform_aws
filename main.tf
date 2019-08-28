provider "aws" {
  region = "${var.my_region}"
}

# data "aws_availability_zone" "zone_alpha" {
#   name = "eu-west-1a"
# }

resource "aws_vpc" "group1_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "dedicated"
  tags ={
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public-subnet-alpha" {
  # vpc_id = "${var.my_vpc_id}"
  vpc_id = "${aws_vpc.group1_vpc.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "public-subnet-alpha"
  }
}

resource "aws_subnet" "public-subnet-beta" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "public-subnet-beta"
  }
}

resource "aws_subnet" "public-subnet-gamma" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  cidr_block = "10.0.12.0/24"
  availability_zone = "eu-west-1c"
  tags = {
    Name = "public-subnet-gamma"
  }
}

resource "aws_subnet" "private-subnet-db" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  cidr_block = "10.0.13.0/24"
  tags = {
    Name = "private-subnet-db"
  }
}

resource "aws_network_acl" "acl_public_sub" {
  vpc_id = "${aws_vpc.group1_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  },
  {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "10.0.13.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  },
  {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "10.0.13.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  tags = {
    Name = "acl_public_sub"
  }
}

resource "aws_network_acl" "acl_private_sub" {
  vpc_id = "${aws_vpc.group1_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 27017
    to_port    = 27017
  },
  {
    protocol   = "tcp"
    rule_no    = 111
    action     = "allow"
    cidr_block = "10.0.11.0/24"
    from_port  = 27017
    to_port    = 27017
  },{
      protocol   = "tcp"
      rule_no    = 112
      action     = "allow"
      cidr_block = "10.0.12.0/24"
      from_port  = 27017
      to_port    = 27017
    }

  ingress {
      protocol   = "tcp"
      rule_no    = 210
      action     = "allow"
      cidr_block = "10.0.10.0/24"
      from_port  = 27017
      to_port    = 27017
    },
    {
      protocol   = "tcp"
      rule_no    = 211
      action     = "allow"
      cidr_block = "10.0.11.0/24"
      from_port  = 27017
      to_port    = 27017
    },{
        protocol   = "tcp"
        rule_no    = 212
        action     = "allow"
        cidr_block = "10.0.12.0/24"
        from_port  = 27017
        to_port    = 27017
}
