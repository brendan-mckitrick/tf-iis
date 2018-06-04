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

resource "aws_db_subnet_group" "db_subnet_group" {
  name                          = "db_subnet_group"
  subnet_ids                    = ["${aws_subnet.private.*.id}"]

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
  db_subnet_group_name          = "${aws_db_subnet_group.db_subnet_group.name}"
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
