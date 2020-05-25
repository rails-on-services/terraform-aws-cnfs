
output "lb" {
  value = aws_lb.this
}

output "lb_route53_record" {
  value = aws_route53_record.lb
}
