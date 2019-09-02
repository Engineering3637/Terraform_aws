provider "aws" {
  region = "${var.my_region}"
  # access_key = "{env.AWS_ACCESS_KEY_ID}"
  # secret_key = "{env.AWS_SECRET_ACCESS_KEY}"
}

resource "aws_vpc" "group1_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
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

resource "aws_subnet" "public-subnet-elk" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  cidr_block = "10.0.14.0/24"
  tags = {
    Name = "elk_public_subnet"
  }
}

resource "aws_network_acl" "acl_public_sub" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  subnet_ids = ["${aws_subnet.public-subnet-alpha.id}","${aws_subnet.public-subnet-beta.id}","${aws_subnet.public-subnet-gamma.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 101
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
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }


  egress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "10.0.13.0/24"
    from_port  = 27017
    to_port    = 27017
  }
  egress {
    protocol   = "tcp"
    rule_no    = 105
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 106
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  egress {
    protocol   = "tcp"
    rule_no    = 107
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "acl_public_sub"
  }
}

#elk subnet acl

resource "aws_network_acl" "acl_public_elk" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  subnet_ids = ["${aws_subnet.public-subnet-elk.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9200
    to_port    = 9300
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 5430
    to_port    = 5430
  }

  egress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl_public_elk"
  }
}

resource "aws_network_acl" "acl_private_sub" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  subnet_ids = ["${aws_subnet.private-subnet-db.id}"]


  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 27017
    to_port    = 27017
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 111
    action     = "allow"
    cidr_block = "10.0.11.0/24"
    from_port  = 27017
    to_port    = 27017
  }
  ingress {
      protocol   = "tcp"
      rule_no    = 112
      action     = "allow"
      cidr_block = "10.0.12.0/24"
      from_port  = 27017
      to_port    = 27017
    }

  egress {
      protocol   = "tcp"
      rule_no    = 210
      action     = "allow"
      cidr_block = "10.0.10.0/24"
      from_port  = 1024
      to_port    = 65535
    }
    egress {
      protocol   = "tcp"
      rule_no    = 211
      action     = "allow"
      cidr_block = "10.0.11.0/24"
      from_port  = 1024
      to_port    = 65535
    }
    egress {
        protocol   = "tcp"
        rule_no    = 212
        action     = "allow"
        cidr_block = "10.0.12.0/24"
        from_port  = 1024
        to_port    = 65535
    }

    tags = {
      Name = "acl_private_sub"
    }
}

resource "aws_instance" "apple_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.public-subnet-alpha.id}"
  vpc_security_group_ids = ["${aws_security_group.app_security_group.id}"]
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "apple_instance"
  }
}

resource "aws_instance" "banana_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.public-subnet-beta.id}"
  vpc_security_group_ids = ["${aws_security_group.app_security_group.id}"]
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "banana_instance"
  }
}

resource "aws_instance" "grapes_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.public-subnet-gamma.id}"
  vpc_security_group_ids = ["${aws_security_group.app_security_group.id}"]
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "grapes_instance"
  }
}

resource "aws_instance" "db_instance" {
  ami = "${var.group1_app_ami}"
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.private-subnet-db.id}"
  vpc_security_group_ids = ["${aws_security_group.db_security_group.id}"]
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "db_instance"
  }
}
#group 3 instance
resource "aws_instance" "elk_instance" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  subnet_id ="${aws_subnet.public-subnet-elk.id}"
  vpc_security_group_ids = ["${aws_security_group.elk_security_group.id}"]
  user_data = "${data.template_file.app_elk.rendered}"
  tags = {
    Name  = "elk-TeamELK"
  }
}

resource "aws_security_group" "app_security_group" {
  name = "public_security_group"
  description = "security group for app instances"
  vpc_id = "${aws_vpc.group1_vpc.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.13.0/24"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.0.13.0/24"]
    }
    egress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "public security group"
    }
  }


  resource "aws_security_group" "db_security_group" {
    name        = "db_security_group"
    description = "security group for db"
    vpc_id      = "${aws_vpc.group1_vpc.id}"

    ingress {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.0.10.0/24"]
    }
    ingress {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.0.11.0/24"]
    }
    ingress {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.0.12.0/24"]
    }

    egress {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.12.0/24"]
      #security_groups = "${module.app.security_group.id}"
    }

    tags = {
      Name = "db_security_groups"
    }
  }

  resource "aws_security_group" "elk_security_group" {
    name = "elk_security_group"
    description = "security group for ELK"
    vpc_id = "${aws_vpc.group1_vpc.id}"
    ingress {
      from_port = 9200
      to_port = 9300
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #cidr_block for elk sub
    }
    ingress {
      from_port = 5430
      to_port = 5430
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1" #-1 is all protocols
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name  = "elk-security-group"
    }
  }

resource "aws_internet_gateway" "internet_access" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.group1_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0" #any traffic should go through gate way
    gateway_id = "${aws_internet_gateway.internet_access.id}"
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

resource "aws_route_table_association" "associate_route_table_elk" {
  subnet_id = "${aws_subnet.public-subnet-elk.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

data "template_file" "app_init" {
  template = "${file("./Script/app/init.sh.tpl")}"
}

data "template_file" "app_elk" {
  template = "${file("./Script/app/elk_commands.sh.tpl")}"
}
