provider "aws" {
  region = "${var.my_region}"

}

resource "aws_vpc" "ENG3637_FP" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags ={
    Name = "ENG3637_FP-vpc"
  }
}

resource "aws_subnet" "public-subnet-alpha" {
  # vpc_id = "${var.my_vpc_id}"
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "public-subnet-alpha"
  }
}

resource "aws_subnet" "public-subnet-beta" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "public-subnet-beta"
  }
}

resource "aws_subnet" "public-subnet-gamma" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  cidr_block = "10.0.12.0/24"
  availability_zone = "eu-west-1c"
  tags = {
    Name = "public-subnet-gamma"
  }
}


resource "aws_subnet" "public-subnet-elk" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  cidr_block = "10.0.14.0/24"
  tags = {
    Name = "elk_public_subnet"
  }
}

resource "aws_subnet" "private-subnet-db" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  cidr_block = "10.0.15.0/24"
  tags = {
    Name = "db-private-subnet"
  }
}

resource "aws_network_acl" "acl_public_sub" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  subnet_ids = ["${aws_subnet.public-subnet-alpha.id}","${aws_subnet.public-subnet-beta.id}","${aws_subnet.public-subnet-gamma.id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl_public_sub"
  }
}

#elk subnet acl

resource "aws_network_acl" "acl_public_elk" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  subnet_ids = ["${aws_subnet.public-subnet-elk.id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 102
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
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  subnet_ids = ["${aws_subnet.private-subnet-db.id}"]


  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 110
  #   action     = "allow"
  #   cidr_block = "10.0.10.0/24"
  #   from_port  = 27017
  #   to_port    = 27017
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 111
  #   action     = "allow"
  #   cidr_block = "10.0.11.0/24"
  #   from_port  = 27017
  #   to_port    = 27017
  # }
  # ingress {
  #     protocol   = "tcp"
  #     rule_no    = 112
  #     action     = "allow"
  #     cidr_block = "10.0.12.0/24"
  #     from_port  = 27017
  #     to_port    = 27017
  #   }
  # ingress {
  #     protocol   = "tcp"
  #     rule_no    = 112
  #     action     = "allow"
  #     cidr_block = "10.0.12.0/24"
  #     from_port  = 27017
  #     to_port    = 27017
  #   }
  #
  # egress {
  #     protocol   = "tcp"
  #     rule_no    = 210
  #     action     = "allow"
  #     cidr_block = "10.0.10.0/24"
  #     from_port  = 1024
  #     to_port    = 65535
  #   }
  #   egress {
  #     protocol   = "tcp"
  #     rule_no    = 211
  #     action     = "allow"
  #     cidr_block = "10.0.11.0/24"
  #     from_port  = 1024
  #     to_port    = 65535
  #   }
  #   egress {
  #       protocol   = "tcp"
  #       rule_no    = 212
  #       action     = "allow"
  #       cidr_block = "10.0.12.0/24"
  #       from_port  = 1024
  #       to_port    = 65535
  #   }
  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
    tags = {
      Name = "acl_private_sub"
    }
}

resource "aws_instance" "apple_instance" {
  ami = data.aws_ami.app_ami.id
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
  ami = data.aws_ami.app_ami.id
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
  ami = data.aws_ami.app_ami.id
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

# AWS resource for aws instance - ################# First instance
resource "aws_instance" "db_instance1" {   # the instance and the name of the Instance
  ami = data.aws_ami.db_ami.id
  associate_public_ip_address = true
  #host_ids = 10.0.15.150
  #associate_with_private_ip = 10.0.0.10
  instance_type = "t2.micro" # instance type = t2.micro
  key_name = "DevOpsEngineering3637"
  subnet_id = "${aws_subnet.private-subnet-db.id}"  # the subnet for the instance created below
  vpc_security_group_ids = ["${aws_security_group.db-security-group.id}"]   # the vpc security group created below
  tags = {          # tag
    Name = "mongo-db1"
  }
}

################################# DB Virtual machine 2 #######################################

# AWS resource for aws instance - ################# First instance
resource "aws_instance" "db2_instance" {   # the instance and the name of the Instance
  ami = data.aws_ami.db_ami.id
  associate_public_ip_address = true
  #host_id = 10.0.15.151
  key_name = "DevOpsEngineering3637"
  instance_type = "t2.micro" # instance type = t2.micro
  subnet_id = "${aws_subnet.private-subnet-db.id}"  # the subnet for the instance created below
  vpc_security_group_ids = ["${aws_security_group.db-security-group.id}"]   # the vpc security group created below
  tags = {          # tag
    Name = "mongo-db2"
  }
}

################################# DB Virtual machine 3 #######################################

# AWS resource for aws instance - ################# First instance
resource "aws_instance" "db3_instance" {
  ami = data.aws_ami.db_ami.id
  associate_public_ip_address = true
  #host_id = 10.0.15.152
  key_name = "DevOpsEngineering3637"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.private-subnet-db.id}"
  vpc_security_group_ids = ["${aws_security_group.db-security-group.id}"]
  tags = {
    Name = "mongo-db3"
  }
}
#     static for db instances
resource "aws_network_interface" "multi-ip" {
  subnet_id   = "${aws_subnet.private-subnet-db.id}"
  private_ips = ["10.0.15.150", "10.0.15.151", "10.0.15.152"]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = "${aws_network_interface.multi-ip.id}"
  associate_with_private_ip = "10.0.15.150"
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = "${aws_network_interface.multi-ip.id}"
  associate_with_private_ip = "10.0.15.151"
}

resource "aws_eip" "three" {
  vpc                       = true
  network_interface         = "${aws_network_interface.multi-ip.id}"
  associate_with_private_ip = "10.0.15.152"
}

#group 3 instance
resource "aws_instance" "elk_instance" {
  ami = data.aws_ami.elk_ami.id
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  associate_public_ip_address = true
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
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  timeouts {
    create = "5m"
  }
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

  #
  # resource "aws_security_group" "db_security_group" {
  #   name        = "db_security_group"
  #   description = "security group for db"
  #   vpc_id      = "${aws_vpc.ENG3637_FP.id}"
  #
  #   ingress {
  #     from_port   = 27017
  #     to_port     = 27017
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.10.0/24"]
  #   }
  #   ingress {
  #     from_port   = 27017
  #     to_port     = 27017
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.11.0/24"]
  #   }
  #   ingress {
  #     from_port   = 27017
  #     to_port     = 27017
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.12.0/24"]
  #   }
  #
  #   egress {
  #     from_port   = 1024
  #     to_port     = 65535
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.12.0/24"]
  #     #security_groups = "${module.app.security_group.id}"
  #   }
  #
  #   tags = {
  #     Name = "db_security_groups"
  #   }
  # }
#db-security-group
  resource "aws_security_group" "db-security-group" {
    name = "db-security-group"
    description = "security group for the db"
    vpc_id = "${aws_vpc.ENG3637_FP.id}"

  # inbound traffic
  # ingress {
  #     from_port   = 27017
  #     to_port     = 27017
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.10.0/24"]
  #   }
  #   ingress {
  #     from_port   = 27017
  #     to_port     = 27017
  #     protocol    = "tcp"
  #     cidr_blocks = ["10.0.11.0/24"]
  #   }
    # ingress {
    #   from_port   = 27017
    #   to_port     = 27017
    #   protocol    = "tcp"
    #   cidr_blocks = ["10.0.12.0/24"]
    # }
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # egress {
    #   from_port   = 1024
    #   to_port     = 65535
    #   protocol    = "tcp"
    #   cidr_blocks = ["10.0.12.0/24"]
    #   #security_groups = "${module.app.security_group.id}"
    # }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "db_security_groups"
      }
    }

  resource "aws_security_group" "elk_security_group" {
    name = "elk_security_group"
    description = "security group for ELK"
    vpc_id = "${aws_vpc.ENG3637_FP.id}"

    timeouts {
      create = "5m"
    }
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
      Name  = "elk-security-group"
    }
  }

resource "aws_internet_gateway" "internet_access" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  tags = {
    Name = "internet_gateway_eng3637"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.ENG3637_FP.id}"
  route {
    cidr_block = "0.0.0.0/0" #any traffic should go through gate way
    gateway_id = "${aws_internet_gateway.internet_access.id}"
  }
  tags = {
    Name = "route_tb_eng3637"
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

#app ami information
data "aws_ami" "app_ami" {
  owners = ["self"]
  most_recent = true

  filter {
    name = "name"
    values = ["ENG3637_APP_jenkins-"]
  }

}

data "aws_ami" "elk_ami" {
  owners = ["self"]
  most_recent = true

  filter {
    name = "name"
    values = ["ELKServerImageDevOps3637"]
  }

}

data "aws_ami" "db_ami" {
  owners = ["self"]
  most_recent = true

  filter {
    name = "name"
    values = ["ENG3637_DB_jenkins-"]
  }
}
