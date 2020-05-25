# Create an EC2
resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  user_data = templatefile("${path.module}/templates/userdata-${var.ami_distro}.tpl", {
    ssh_public_keys = var.ssh_public_keys,
    project_name    = var.project_name
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix} ${random_id.ec2.hex}"
  })
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_filter_name_map[var.ami_distro]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.ami_owner_map[var.ami_distro]]
}

resource "random_id" "ec2" {
  byte_length = 8
}

resource "aws_eip" "this" {
  vpc  = true
  tags = var.tags
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}

resource "aws_security_group" "this" {
  name_prefix = "allow-public"
  description = "Allow access from public internet"

  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "ssh_to_ec2" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ec2_from_to_3000" {
  type        = "ingress"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ec2_to_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
