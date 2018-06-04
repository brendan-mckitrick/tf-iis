# public security group
resource "aws_security_group" "public" {
    name                     = "sg_public"
    description              = "Allow incoming HTTP connections."

    ingress {
        from_port            = 80
        to_port              = 80
        protocol             = "tcp"
        cidr_blocks          = ["${var.all_cidr_block}"]
    }

    # SSL rules, assuming it's enabled
    ingress {
        from_port            = 443
        to_port              = 443
        protocol             = "tcp"
        cidr_blocks          = ["${var.all_cidr_block}"]
    }

    egress { # frontend application host, port 80
        from_port            = 80
        to_port              = 80
        protocol             = "tcp"
        security_groups      = ["${aws_security_group.frontend.id}"]
    }

    vpc_id                   = "${aws_vpc.papabravo.id}"

    tags                     = "${merge(
      local.common_tags,
      map(
        "Name", "sg_public",
        "Resource", "aws_security_group"
      )
    )}"
}


# public load balancer
resource "aws_lb" "public" {
  name                       = "alb-frontend" # cannot use underscores in name here
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.public.id}"]
  subnets                    = ["${aws_subnet.public.*.id}"]

  enable_deletion_protection = false # explicitly called out ; true is generally 'safer'

  tags                       = "${merge(
    local.common_tags,
    map(
      "Name", "public ALB",
      "Resource", "aws_lb"
    )
  )}"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn          = "${aws_lb.public.arn}"
  port                       = "80"
  protocol                   = "HTTP"

  default_action {
    target_group_arn         = "${aws_lb_target_group.frontend.arn}"
    type                     = "forward"
  }
}


# target group for frontend
resource "aws_lb_target_group" "frontend" {
  name                       = "frontend"
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
      "Name", "frontendalb_frontend_target_group",
      "Resource", "aws_lb_target_group"
    )
  )}"
}