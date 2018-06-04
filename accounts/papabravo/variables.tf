# variables ; actual values declared in /environments/

variable "region" {
  description = "AWS region"
}

variable "ou" {
  description = "OU for tagging"
}

variable "service" {
  description = "Service this deployment provides, used for tagging"
}

variable "aws_account" {
  description = "AWS account to run Terraform in"
}

variable "iam_user_name" {
  description = "IAM account name to invoke Terraform actions"
}

variable "iam_access_key" {
  description = "Access key for the IAM user to invoke Terraform actions"
}

variable "iam_secret_key" {
  description = "Secret key for the IAM user to invoke Terraform actions"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
}

variable "environment" {
  description = "Default environment"
}


variable "private_subnet_cidrs" {
  description = "List of CIDRs for the private subnets",
  type        = "list"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for the public subnets",
  type      = "list"
}

variable "availability_zones" {
  description = "List of availability zones",
  type = "list"
}

variable "all_cidr_block" {
  description = "The CIDR block for global access ; typically 0.0.0.0/0, but configurable for testing or security-related purposes"
}


variable "papabravo_ami_frontend_name" {
  description = "The AMI name to use for launching the frontend application"
}

variable "papabravo_ami_backend_name" {
  description = "The AMI name to use for launching the backend application"
}

variable "papabravo_ec2_frontend_type" {
  description = "The EC2 instance size for the frontend application"
}

variable "papabravo_ec2_backend_type" {
  description = "The EC2 instance size for the backend application"
}

variable "papabravo_db_size" {
  description = "The EC2 instance size for the RDS database"
}

variable "papabravo_db_password" {
  description = "The password for the database"
}

variable "papabravo_db_engine" {
  description = "The DB engine to use"
}

variable "papabravo_db_engine_version" {
  description = "The DB engine version to use"
}

variable "papabravo_db_storage" {
  description = "The storage (in GB) to provide the DB server"
}
