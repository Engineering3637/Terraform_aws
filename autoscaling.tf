
resource "aws_launch_configuration" "blue-green-launchconfig" {
  name_prefix = "blue-green-launchconfig"
  image_id      = "ami-0016380d21de9083c"
  instance_type = "t2.micro"
  key_name = "DevOpsEngineering3637"
  security_groups = ["${aws_security_group.app_security_group.id}"]
}



resource "aws_autoscaling_group" "blue-green-autoscaling" {
  name = "blue-green-autoscaling"
  vpc_zone_identifier = ["${aws_subnet.public-subnet-alpha.id}", "${aws_subnet.public-subnet-beta.id}", "${aws_subnet.public-subnet-gamma.id}"]
  launch_configuration = "${aws_launch_configuration.blue-green-launchconfig.name}"
  min_size = 1
  max_size = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  tag {
      key = "Name"
      value = "ec2 instance"
      propagate_at_launch = true
    }
}
