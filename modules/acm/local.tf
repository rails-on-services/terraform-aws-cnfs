locals {
  # deduplicate the domain_validation_options
  cert_dns_validations = tolist(toset([
    for o in aws_acm_certificate.this.domain_validation_options :
    {
      resource_record_name  = o.resource_record_name
      resource_record_type  = o.resource_record_type
      resource_record_value = o.resource_record_value
    }
  ]))
}