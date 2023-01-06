#別でドメインを取得するため事前に作成し、DNSを変更しておく。故にdataで取得する
data "aws_route53_zone" "main" {
  name = var.zone
  private_zone = false
}

#----------------------------
# ACM
#----------------------------
resource "aws_acm_certificate" "main" {
  domain_name = var.domain

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main" {
  for_each = {
  for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id

  depends_on = [aws_acm_certificate.main]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}