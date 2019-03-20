# Create VPC
resource "aws_vpc" "ate-vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = "${merge(
    var.common-tags, 
    map(
      "Name", "${var.environment}-${var.project}" 
  ))}"
}

# Create public and private subnets in this VPC
resource "aws_subnet" "ate-public-1a" {
  vpc_id            = "${aws_vpc.ate-vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = "${merge(
    var.common-tags, 
    map(
      "Name", "${var.environment}-${var.project}-public-1a"
  ))}" 
}

resource "aws_subnet" "ate-private-1a" {
  vpc_id            = "${aws_vpc.ate-vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.101.0/24"

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-private-1a"
  ))}"   
}

# Create igw for pubic subnets
resource "aws_internet_gateway" "ate-igw" {
  vpc_id = "${aws_vpc.ate-vpc.id}"

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-igw"
  ))}" 
}

# Create public route table 
resource "aws_route_table" "ate-rtb-public" {
  vpc_id = "${aws_vpc.ate-vpc.id}"

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-rtb-public"
  ))}"  
}

# Create internet route in public route table and assign in public subnet 
resource "aws_route" "ate-route-public" {
  route_table_id = "${aws_route_table.ate-rtb-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ate-igw.id}"
}

resource "aws_route_table_association" "ate-route-public-assn" {
  route_table_id = "${aws_route_table.ate-rtb-public.id}"
  subnet_id = "${aws_subnet.ate-public-1a.id}"
}

#and private route table
resource "aws_default_route_table" "ate-rtb-private" {
  default_route_table_id = "${aws_vpc.ate-vpc.main_route_table_id}"

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-rtb-private"
  ))}"  
}



