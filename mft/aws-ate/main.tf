resource "aws_vpc" "prd-ate" {
  cidr_block = "100.1.0.0/16"
  tags = {
    Name = "prd-ate"
  }
}