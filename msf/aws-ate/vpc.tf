# Create VPC
resource "aws_vpc" "ate-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.environment}-${var.project}"
  }
}

# Create public and private subnets in this VPC
resource "aws_subnet" "ate-public-1a" {
  vpc_id = "${aws_vpc.ate-vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "${var.environment}-${var.project}-public-1a"
  }
}

resource "aws_subnet" "ate-private-1a" {
  vpc_id = "${aws_vpc.ate-vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.101.0/24"
  tags = {
    Name = "${var.environment}-${var.project}-private-1a"
  }
}

# Create igw for pubic subnet
resource "aws_internet_gateway" "ate-igw" {
  vpc_id = "${aws_vpc.ate-vpc.id}"
  tags = {
    Name = "${var.environment}-${var.project}-igw"
  }
}

# Create internet route in main route table and assign in public subnet 
resource "aws_route" "ate-public-route" {
  route_table_id = "${aws_vpc.ate-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ate-igw.id}"
}

resource "aws_route_table_association" "ate-public-route-assn" {
  route_table_id = "${aws_vpc.ate-vpc.main_route_table_id}"
  subnet_id = "${aws_subnet.ate-public-1a.id}"
}

