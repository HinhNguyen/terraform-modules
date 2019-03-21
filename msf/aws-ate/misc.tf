# Create 2 ECR. 
resource "aws_ecr_repository" "ate-ecr-api" {
  name = "${var.environment}-${var.project}-api"
}

resource "aws_ecr_repository" "ate-ecr-dashboard" {
  name = "${var.environment}-${var.project}-dashboard"
}

# User ate can put image to these ecr via bitbucket pipeline with access key 
data "aws_iam_policy" "aws-ecr-power-user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_user_policy_attachment" "ate-user-attachment" {
  user = "${aws_iam_user.ate-user.name}"
  policy_arn = "${data.aws_iam_policy.aws-ecr-power-user.arn}"
}

# Create security groups
resource "aws_security_group" "ate-sg-ssh-ext" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-ssh-ext"
  description = "Allow SSH from external (Internet) to Bastion host - inbound traffic"

  ingress = {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from internet to bastion host"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-sg-ssh-ext"
  ))}" 
}

resource "aws_security_group" "ate-sg-ssh-int" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-ssh-int"
  description = "Allow SSH from bastion host to internal network - inbound traffic"

  ingress = {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ate-sg-ssh-ext.id}"]
    description = "SSH from bastion host"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-sg-ssh-int"
  ))}" 
}

resource "aws_security_group" "ate-sg-app" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-app"
  description = "Allow HTTP/HTTPS from external (Internet) to App server - inbound traffic"

  ingress = {
    from_port   = "8123"
    to_port     = "8124"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS ports to nginx container inside app server"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-sg-app"
  ))}" 
}

resource "aws_security_group" "ate-sg-db" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-db"
  description = "Allow DB connection from internal network to DB server - inbound traffic"

  ingress = {
    from_port   = "27017"
    to_port     = "27017"
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ate-sg-ssh-int.id}"]
    description = "MongodDB connection"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-sg-db"
  ))}" 
}

resource "aws_security_group" "ate-sg-icmp" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-icmp"
  description = "Allow ICMP from internal network - inbound traffic"

  ingress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "icmp"
    security_groups = ["${aws_security_group.ate-sg-ssh-int.id}"]
    description = "ICMP ping from internal"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${var.common-tags}"
}

resource "aws_security_group" "ate-sg-office" {
  vpc_id      = "${aws_vpc.ate-vpc.id}"
  name        = "${var.environment}-${var.project}-sg-office"
  description = "Allow connection from Fossil VN office - inbound traffic"

  ingress = {
    from_port   = "3000"
    to_port     = "3000"
    protocol    = "tcp"
    cidr_blocks = ["45.125.206.120/30", "45.125.205.200/29", "45.125.206.124/30", "45.125.210.8/29"]
    description = "Fossil VN office IP"
  }

  egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = "${merge(
    var.common-tags,
    map(
      "Name", "${var.environment}-${var.project}-sg-office"
  ))}" 
}