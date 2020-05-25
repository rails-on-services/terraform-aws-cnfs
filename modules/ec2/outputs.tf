output "this" {
  value = aws_instance.this
}

output "eip" {
  value = aws_eip.this
}

output "security_group_id" {
  value = aws_security_group.this.id
}
