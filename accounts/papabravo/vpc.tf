# setup vpc
resource "aws_vpc" "papabravo" {
  cidr_block        = "${var.cidr_block}"
  tags              = "${merge(
    local.common_tags,
    map(
      "Name", "papabravo",
      "Resource", "aws_vpc"
    )
  )}"
}

# attach internet gateway
resource "aws_internet_gateway" "papabravo" {
    vpc_id          = "${aws_vpc.papabravo.id}"
    tags            = "${merge(
      local.common_tags,
      map(
        "Name", "papabravo",
        "Resource", "aws_internet_gateway"
      )
    )}"
}

# declare subnets as supplied by variables files
resource "aws_subnet" "private" {
  count             = "${length(var.private_subnet_cidrs)}"

  vpc_id            = "${aws_vpc.papabravo.id}"
  cidr_block        = "${var.private_subnet_cidrs[count.index]}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags              = "${merge(
    local.common_tags,
    map(
      "Name", "private subnet",
      "Resource", "aws_subnet"
    )
  )}"
}

resource "aws_subnet" "public" {
  count             = "${length(var.public_subnet_cidrs)}"

  vpc_id            = "${aws_vpc.papabravo.id}"
  cidr_block        = "${var.public_subnet_cidrs[count.index]}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags              = "${merge(
    local.common_tags,
    map(
      "Name", "public subnet",
      "Resource", "aws_subnet"
    )
  )}"
}


# set route table for internet gateway
resource "aws_route_table" "public" {
  vpc_id            = "${aws_vpc.papabravo.id}"

  route {
    cidr_block      = "${var.all_cidr_block}"
    gateway_id      = "${aws_internet_gateway.papabravo.id}"
  }
  tags              = "${merge(
    local.common_tags,
    map(
      "Name", "public route table",
      "Resource", "aws_route_table"
    )
  )}"

}

# because I'm not setting the above route table as "main", need to explicitly
# associate the route tables with each subnet
resource "aws_route_table_association" "a" {

  count             = "${length(var.public_subnet_cidrs)}"

  subnet_id         = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id    = "${aws_route_table.public.id}"
}
