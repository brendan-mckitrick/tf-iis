# security groups for database hosts, accepting connections from backend application hosts only
resource "aws_security_group" "database" {
    name                        = "sg_database"
    description                 = "Allow connections to database assets"

    vpc_id                      = "${aws_vpc.papabravo.id}"

    tags                        = "${merge(
      local.common_tags,
      map(
        "Name", "database",
        "Resource", "aws_security_group"
      )
    )}"
}

# ingress rules need to be declared separately to avoid the annoying "Cycle" error
resource "aws_security_group_rule" "database_ingress" {
  type                          = "ingress"
  from_port                     = "1443"
  to_port                       = "1443"
  protocol                      = "tcp"
  security_group_id             = "${aws_security_group.database.id}"
  source_security_group_id      = "${aws_security_group.backend_application.id}"
}

resource "aws_db_subnet_group" "default" {
  name                          = "db_subnet_group"
  subnet_ids                    = ["${aws_subnet.private.*.id}"]

    # subnet_id                 = "${element(aws_subnet.private.*.id, count.index)}"

  tags                          = "${merge(
    local.common_tags,
    map(
      "Name", "db_subnet_group",
      "Resource", "aws_db_subnet_group"
    )
  )}"
}



resource "aws_db_instance" "database" {
  allocated_storage             = "${var.papabravo_db_storage}"
  storage_type                  = "gp2"
  engine                        = "${var.papabravo_db_engine}"
  skip_final_snapshot           = "true" # dangerous ; will delete DB straight away
  engine_version                = "${var.papabravo_db_engine_version}"
  db_subnet_group_name          = "db_subnet_group"
  instance_class                = "${var.papabravo_db_size}"
  license_model                 = "license-included"
  # name                        = "papabravodb"
  username                      = "admin"
  password                      = "${var.papabravo_db_password}"
  vpc_security_group_ids        = ["${aws_security_group.database.id}"]

  tags                          = "${merge(
    local.common_tags,
    map(
      "Name", "database",
      "Resource", "aws_db_instance"
    )
  )}"
}












#
#
# # security group
# resource "aws_security_group" "backend" {
# name                          = "sg_backend"
# description                   = "Allow connections to backend assets"
#
# ingress {
# from_port                     = 80
# to_port                       = 80
# protocol                      = "tcp"
# security_groups               = ["${aws_security_group.public.id}"]
# }
#
# # egress { # frontend application host, port 80
# # from_port                   = 80
# # to_port                     = 80
# # protocol                    = "tcp"
# # cidr_blocks                 = ["${var.private_subnet_cidrs}"]
# # }
#
# vpc_id                        = "${aws_vpc.papabravo.id}"
#
# tags                          = "${merge(
# local.common_tags,
# map(
# "Name", "sg_backend",
# "Resource", "aws_security_group"
# )
# )}"
# }
#
#
#
#
# # declare launch configuration and ASG for the frontend application
# resource "aws_launch_configuration" "frontend_config" {
# name                          = "frontend_config"
# image_id                      = "${data.aws_ami.papabravo_ami_frontend.id}"
# instance_type                 = "t2.micro"
# security_groups               = ["${aws_security_group.frontend.id}"]
#
# lifecycle {
# create_before_destroy         = true
# }
#
# }
#
# resource "aws_autoscaling_group" "frontend" {
# name                          = "frontend_asg"
# launch_configuration          = "${aws_launch_configuration.frontend_config.name}"
# min_size                      = 2
# max_size                      = 2
# vpc_zone_identifier           = ["${aws_subnet.private.*.id}"]
#
# lifecycle {
# create_before_destroy         = true
# }
#
# # tags                        = "${merge(
# # local.common_tags,
# # map(
# # "Name", "frontend ASG",
# # "Resource", "aws_autoscaling_group"
# # )
# # )}"
#
# }
#
# # Create a new ALB Target Group attachment
# resource "aws_autoscaling_attachment" "asg_attachment_bar" {
# autoscaling_group_name        = "${aws_autoscaling_group.frontend.id}"
# alb_target_group_arn          = "${aws_lb_target_group.frontend.arn}"
# }
#
#
#
#
# #
# # resource "aws_instance" "web-1" {
# # ami                         = "${lookup(var.amis, var.aws_region)}"
# # availability_zone           = "eu-west-1a"
# # instance_type               = "m1.small"
# # key_name                    = "${var.aws_key_name}"
# # vpc_security_group_ids      = ["${aws_security_group.web.id}"]
# # subnet_id                   = "${aws_subnet.eu-west-1a-public.id}"
# # associate_public_ip_address = true
# # source_dest_check           = false
# #
# #
# # tags {
# # Name                        = "Web Server 1"
# # }
# # }
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# #----------------------------- VPC ------------------------------ #
#
