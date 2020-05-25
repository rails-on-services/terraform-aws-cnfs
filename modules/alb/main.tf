
# Create the load balancer
resource "aws_lb" "this" {
  name_prefix        = var.name_prefix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.subnet_ids

  tags = var.tags
}

# Create a target group to forward taffic to
resource "aws_lb_target_group" "this" {
  name_prefix = var.name_prefix
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  # the nginx listens on port 3000
  port = 3000

  health_check {
    path              = "/healthz"
    matcher           = "200"
    interval          = 10
    healthy_threshold = 2
  }
}

# Attach the EC2 to this target group
resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.this.id
}

# Add an http listner on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Add an https listner on port 443
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Add a security group to the Load balancer
resource "aws_security_group" "lb" {
  name_prefix = "allow-lb-public"
  description = "Allow access load balancer from public internet"

  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow load balancer to reach out to instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add a rule to the ec2 security group to allow load balancer traffic to reach the instance
resource "aws_security_group_rule" "ec2_from_lb" {
  type = "ingress"
  from_port       = 3000
  to_port         = 3000
  protocol        = "tcp"
  security_group_id = aws_security_group.ec2.id
  # source_security_group_id = aws_security_group.lb.id
  source_security_group_id = var.ec2_security_group_id
}

resource "aws_route53_record" "lb" {
  count   = length(var.lb_dns_hostnames) != 0 ? length(var.lb_dns_hostnames) : 0
  zone_id = var.route53_zone_id
  name    = var.lb_dns_hostnames[count.index]
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.this.dns_name]
}
