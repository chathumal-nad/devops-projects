resource "aws_acm_certificate" "certificates" {
  for_each          = var.domains
  domain_name       = each.key
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 DNS validation records
resource "aws_route53_record" "certificates-validation-records" {
  for_each = {
    for cert in aws_acm_certificate.certificates : tolist(cert.domain_validation_options)[0].domain_name => {
      resource_record_name  = tolist(cert.domain_validation_options)[0].resource_record_name
      resource_record_type  = tolist(cert.domain_validation_options)[0].resource_record_type
      resource_record_value = tolist(cert.domain_validation_options)[0].resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = var.dns_zone_id
}


resource "aws_acm_certificate_validation" "certificates-validations" {
  for_each                = var.domains
  certificate_arn         = aws_acm_certificate.certificates[each.key].arn
  validation_record_fqdns = [aws_route53_record.certificates-validation-records[each.key].fqdn]
}
