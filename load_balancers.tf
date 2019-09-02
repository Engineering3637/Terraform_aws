
resource "aws_elb" "terraform-blue-green" {
  name            = "terraform-blue-green-${var.name}"
  subnets         = ["${aws_subnet.public-subnet-alpha.id}", "${aws_subnet.public-subnet-beta.id}", "${aws_subnet.public-subnet-gamma.id}"]
  # security_groups = ["${aws_security_group.app_security_group.id}"]
  #
  # instances = ["${aws_instance.adam-apple_instance.id}", "${aws_instance.adam-banana_instance.id}", "${aws_instance.adam-grapes_instance.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  #
  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   timeout             = 3
  #   target              = "HTTP:80/"
  #   interval            = 30
  # }


}

output "load_balancer_dns" {
  value = "${aws_elb.terraform-blue-green.dns_name}"
}
