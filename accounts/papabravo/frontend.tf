# security groups for frontend and backend
resource "aws_security_group" "frontend" {
    name                   = "sg_frontend"
    description            = "Allow connections to frontend assets"

    egress { # frontend application host, port 80
      from_port            = 80
      to_port              = 80
      protocol             = "tcp"
      cidr_blocks          = ["${var.private_subnet_cidrs}"]
    }

    vpc_id                 = "${aws_vpc.papabravo.id}"

    tags                   = "${merge(
      local.common_tags,
      map(
        "Name", "sg_frontend",
        "Resource", "aws_security_group"
      )
    )}"
}

# ingress rules need to be declared separately to avoid the annoying "Cycle" error
resource "aws_security_group_rule" "frontend_ingress" {
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.frontend.id}"
  source_security_group_id = "${aws_security_group.public.id}"
}

# declare launch configuration and ASG for the frontend application
resource "aws_launch_configuration" "frontend_config" {
  # name                   = "frontend_config"
  image_id                 = "${data.aws_ami.papabravo_ami_frontend.id}"
  instance_type            = "${var.papabravo_ec2_frontend_type}"
  security_groups          = ["${aws_security_group.frontend.id}"]

  lifecycle {
    create_before_destroy  = true
  }

}

resource "aws_autoscaling_group" "frontend" {
  name                     = "frontend_asg"
  launch_configuration     = "${aws_launch_configuration.frontend_config.name}"
  min_size                 = 2
  max_size                 = 2
  vpc_zone_identifier      = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy  = true
  }

}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name   = "${aws_autoscaling_group.frontend.id}"
  alb_target_group_arn     = "${aws_lb_target_group.frontend.arn}"
}




