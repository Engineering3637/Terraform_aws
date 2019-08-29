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
  }
  egress {
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
  }
  ingress {
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
  }
  egress {
    protocol   = "tcp"
    rule_no    = 111
    action     = "allow"
    cidr_block = "10.0.11.0/24"
    from_port  = 27017
    to_port    = 27017
  }
  egress {
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
    }
    ingress {
      protocol   = "tcp"
      rule_no    = 211
      action     = "allow"
      cidr_block = "10.0.11.0/24"
      from_port  = 27017
      to_port    = 27017
    }
    ingress {
        protocol   = "tcp"
        rule_no    = 212
        action     = "allow"
        cidr_block = "10.0.12.0/24"
        from_port  = 27017
        to_port    = 27017
    }
}

resource "aws_instance" "apple_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public-subnet-alpha.id}"
  #user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "instance-alpha"
  }
}

resource "aws_instance" "banana_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public-subnet-beta.id}"
  #user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "instance-banana"
  }
}

resource "aws_instance" "grapes_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public-subnet-gamma.id}"
  #user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "instance-grapes"
  }
}

resource "aws_instance" "db_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.private-subnet-db.id}"
  #user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "instance-grapes"
  }
}

data "aws_internet_gateway" "default" {
  filter {
    name = "attachment.vpc-id"
    values = ["${aws_vpc.group1_vpc.id}"]
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0" #any traffic should go through gate way
    gateway_id = "${data.aws_internet_gateway.default.id}"
  }
  tags = {
    Name = "main_route"
  }
}

resource "aws_route_table_association" "associate_route_table_alpha" {
  subnet_id = "${aws_subnet.public-subnet-alpha.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "associate_route_table_beta" {
  subnet_id = "${aws_subnet.public-subnet-beta.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "associate_route_table_gamma" {
  subnet_id = "${aws_subnet.public-subnet-gamma.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "associate_route_table_db" {
  subnet_id = "${aws_subnet.private-subnet-db.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
