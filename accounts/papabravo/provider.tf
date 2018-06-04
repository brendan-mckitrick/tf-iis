# provider details and defaults

provider "aws" {
  version     = "~> 1.8"
  region      = "${var.region}"
  access_key  = "${var.iam_access_key}"
  secret_key  = "${var.iam_secret_key}"
}

# Use locals to declare common tags to be applied
locals {
  common_tags = "${map(
    "Client", "${var.ou}",
    "Environment", "${var.environment}",
    "Service", "${var.service}"
  )}"
}

# Declare application AMI's to use

data "aws_ami" "papabravo_ami_frontend" {
  most_recent = true
  filter {
    name      = "name"
    values    = ["${var.papabravo_ami_frontend_name}"]
  }
}

data "aws_ami" "papabravo_ami_backend" {
  most_recent = true
  filter {
    name      = "name"
    values    = ["${var.papabravo_ami_backend_name}"]
  }
}
