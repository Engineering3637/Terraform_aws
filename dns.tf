data "aws_route53_zone" "terraform-blue-green" {
  name = "yourdomain.com"
}

resource "aws_route53_record" "terraform-blue-green" {
  zone_id = "${data.aws_route53_zone.terraform-blue-green.id}"
  name    = "v1.yourdomain.com"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_elb.terraform-blue-green.name}"
    zone_id                = "${aws_elb.terraform-blue-green.zone_id}"
    evaluate_target_health = false
  }
}
