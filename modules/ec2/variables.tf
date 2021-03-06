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

variable "project_name" {
  default     = "dev"
  type        = string
  description = "The project name used by cloud-init userdata"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type    = list
  default = []
}

variable "instance_type" {
  default = "t3.large"
}

variable "ami_distro" {
  default     = "debian"
  description = "The EC2 ami linux distro to use, can be debian or ubuntu"
}

variable "key_name" {
  default     = null
  description = "EC2 ssh key pair name to use"
}

variable "ssh_public_keys" {
  default     = []
  type        = list
  description = "List of public keys to add to the instance's ~/.ssh/authorized_keys"
}
