# Create VPC
resource "aws_vpc" "ate-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.environment}-${var.project}"
  }
}

# Create subnet
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
