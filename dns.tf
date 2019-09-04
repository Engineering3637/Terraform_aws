# data "aws_route53_zone" "terraform-blue-green" {
#
#   private_zone = false
#   zone_id = "Z2PBW64GHBWHX4"
#   vpc_id = "${aws_vpc.adam_vpc.id}"
# }

resource "aws_route53_zone" "main" {
  name = "ec2-34-244-63-130.eu-west-1.compute.amazonaws.com"
}
resource "aws_route53_zone" "dev" {
  name = "dev.ec2-34-244-63-130.eu-west-1.compute.amazonaws.com"

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "dev.ec2-34-244-63-130.eu-west-1.compute.amazonaws.com"
  type    = "NS"
  ttl = 30

  records = [
    "${aws_route53_zone.dev.name_servers.0}"
  ]

#   alias {
#     name                   = "${aws_elb.terraform-blue-green1.name}"
#     zone_id                = "${aws_elb.terraform-blue-green1.zone_id}"
#     evaluate_target_health = true
#   }
 }
