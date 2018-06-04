region                        = "eu-west-1"
environment                   = "prod"
ou                            = "papabravo"
service                       = "ecommerce_website"

#--------------------------------NETWORK ----------------------------- #

cidr_block                    = "10.2.0.0/21"
private_subnet_cidrs          = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
public_subnet_cidrs           = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
availability_zones            = ["eu-west-1a","eu-west-1b","eu-west-1c"]
all_cidr_block                = "0.0.0.0/0"

#-----------------------------PAPABRAVO ----------------------------- #

papabravo_state_filename      = "papabravo.tfstate"
# papabravo_ami_frontend_name = "Windows_Server-2016-English-Core-Base-2018.05.09" # From https://aws.amazon.com/windows/resources/amis/
# papabravo_ami_backend_name  = "Windows_Server-2016-English-Core-Base-2018.05.09"
papabravo_ami_frontend_name   = "apache-port-80"
papabravo_ami_backend_name    = "apache-port-80"
papabravo_ec2_frontend_type   = "t2.medium"
papabravo_ec2_backend_type    = "t2.medium"
papabravo_db_password         = "foobarbaz"

# Consult the AWS documentation to ensure the following combination of
# parameters is supported by RDS
papabravo_db_engine           = "sqlserver-ex" # limited to small instance sizes, storage and single AZ
papabravo_db_size             = "db.t2.micro"
papabravo_db_storage          = 20 # storage in GB
papabravo_db_engine_version   = "13.00.4422.0.v1"



