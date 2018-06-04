# backend load balancer
resource "aws_lb" "backend" {
  name                       = "alb-backend" # cannot use underscores in name here
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.backend_load_balancer.id}"]
  subnets                    = ["${aws_subnet.private.*.id}"]

  enable_deletion_protection = false

  # access_logs {
  # bucket                   = "${aws_s3_bucket.lb_logs.bucket}"
  # prefix                   = "test-lb"
  # enabled                  = true
  # }

  tags                       = "${merge(
    local.common_tags,
    map(
      "Name", "backend ALB",
      "Resource", "aws_lb"
    )
  )}"
}


resource "aws_lb_listener" "backend" {
  load_balancer_arn          = "${aws_lb.backend.arn}"
  port                       = "80"
  protocol                   = "HTTP"

  default_action {
    target_group_arn         = "${aws_lb_target_group.backend_application.arn}"
    type                     = "forward"
  }
}

# security groups for backend application
resource "aws_security_group" "backend_application" {
    name                     = "sg_backend_application"
    description              = "Allow connections to backend application hosts from frontend hosts"

    vpc_id                   = "${aws_vpc.papabravo.id}"

    tags                     = "${merge(
      local.common_tags,
      map(
        "Name", "backend_application",
        "Resource", "aws_security_group"
      )
    )}"

    egress { # frontend application host, port 80
      from_port              = 80
      to_port                = 80
      protocol               = "tcp"
      cidr_blocks            = ["${var.private_subnet_cidrs}"]
    }
}

# ingress rules need to be declared separately to avoid the annoying "Cycle" error
resource "aws_security_group_rule" "backend_application_ingress" {
  type                       = "ingress"
  from_port                  = "80"
  to_port                    = "80"
  protocol                   = "tcp"
  security_group_id          = "${aws_security_group.backend_application.id}"
  source_security_group_id   = "${aws_security_group.backend_load_balancer.id}"
}


# security groups for backend load balancer
resource "aws_security_group" "backend_load_balancer" {
    name                     = "sg_backend_load_balancer"
    description              = "Allow connections to backend application hosts from frontend hosts"

    vpc_id                   = "${aws_vpc.papabravo.id}"

    tags                     = "${merge(
      local.common_tags,
      map(
        "Name", "sg_backend_load_balancer",
        "Resource", "aws_security_group"
      )
    )}"

    egress { # frontend application host, port 80
      from_port              = 80
      to_port                = 80
      protocol               = "tcp"
      cidr_blocks            = ["${var.private_subnet_cidrs}"]
    }
}


# ingress rules need to be declared separately to avoid the annoying "Cycle" error
resource "aws_security_group_rule" "backend_load_balancer_ingress" {
  type                       = "ingress"
  from_port                  = "80"
  to_port                    = "80"
  protocol                   = "tcp"
  security_group_id          = "${aws_security_group.backend_load_balancer.id}"
  source_security_group_id   = "${aws_security_group.frontend.id}"
}


# declare launch configuration and ASG for the backend application
resource "aws_launch_configuration" "backend_application_config" {
  # name                     = "backend_application_config"
  image_id                   = "${data.aws_ami.papabravo_ami_backend.id}"
  instance_type              = "${var.papabravo_ec2_frontend_type}"
  security_groups            = ["${aws_security_group.backend_application.id}"]

  lifecycle {
    create_before_destroy    = true
  }

}

resource "aws_autoscaling_group" "backend" {
  name                       = "backend_asg"
  launch_configuration       = "${aws_launch_configuration.backend_application_config.name}"
  min_size                   = 2
  max_size                   = 2
  vpc_zone_identifier        = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy    = true
  }

}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_backend" {
  autoscaling_group_name     = "${aws_autoscaling_group.backend.id}"
  alb_target_group_arn       = "${aws_lb_target_group.backend_application.arn}"
}

# target group for backend application
resource "aws_lb_target_group" "backend_application" {
  name                       = "backend-application"
  port                       = 80
  protocol                   = "HTTP"
  stickiness                 = {
    enabled                  = true,
    cookie_duration          = "1800",
    type                     = "lb_cookie"
  }

  health_check               = {
    path                     = "/",
    port                     = "80",
    matcher                  = "200-299"
  }

  vpc_id                     = "${aws_vpc.papabravo.id}"
  tags                       = "${merge(
    local.common_tags,
    map(
      "Name", "alb_backend_application_target_group",
      "Resource", "aws_lb_target_group"
    )
  )}"
}


