
resource "aws_elb" "terraform-blue-green1" {
  name            = "terraform-blue-green-${var.name}"
  subnets         = ["${aws_subnet.public-subnet-adam1.id}", "${aws_subnet.public-subnet-adam2.id}", "${aws_subnet.public-subnet-adam3.id}"]
  security_groups = ["${aws_security_group.app_security_group_adam.id}"]
  #
  instances = ["${aws_instance.apple_instance.id}", "${aws_instance.banana_instance.id}", "${aws_instance.grapes_instance.id}"]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

}

output "load_balancer_dns" {
  value = "${aws_elb.terraform-blue-green1.name}"
}
