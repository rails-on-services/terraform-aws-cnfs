locals {
  ami_filter_name_map = {
    # https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
    debian = "debian-10-amd64-*"
    ubuntu = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  }

  ami_owner_map = {
    debian = "136693071363"
    ubuntu = "099720109477"
  }

  ami_ssh_user_map = {
    debian = "admin"
    ubuntu = "ubuntu"
  }
}
