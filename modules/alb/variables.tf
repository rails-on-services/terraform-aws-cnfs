variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the created resources"
}

variable "name_prefix" {
  default     = "cnfs"
  type        = string
  description = "Name prefix for created resources"
}

variable "subnet_ids" {
  type    = list
  default = []
}

variable "ec2_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "acm_arn" {
  default     = ""
  type        = string
  description = "AWS ACM cert arn to be used by the created load balancer"
}

variable "lb_dns_hostnames" {
  default     = []
  type        = list
  description = "Optional, DNS records for adding to route53 for the load balancer"
}

variable "route53_zone_id" {
  default     = ""
  type        = string
  description = "Optional, Route53 hosted zone ID to add records into, mandatory if lb_dns_hostnames is specified"
}
