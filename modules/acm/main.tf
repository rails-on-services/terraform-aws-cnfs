data "aws_route53_zone" "selected" {
  name         = coalesce("${var.route53_domain_name}.", "${var.domain_name}.")
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count = var.route53_dns_record_count

  name    = local.cert_dns_validations[count.index].resource_record_name
  type    = local.cert_dns_validations[count.index].resource_record_type
  zone_id = data.aws_route53_zone.selected.zone_id
  records = [local.cert_dns_validations[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  count = var.validate_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}

