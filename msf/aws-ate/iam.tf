# Create ATE user to get api access key
resource "aws_iam_user" "ate-user" {
  name = "${var.environment}-${var.project}"
  path = "/"
}

resource "aws_iam_access_key" "ate-access-key" {
  user = "${aws_iam_user.ate-user.name}"
  # pgp_key = "" should use pgp key in next ver
}

output "ate-key-id" {
  value = "${aws_iam_access_key.ate-access-key.id}"
}

output "ate-key-secret" {
  value = "${aws_iam_access_key.ate-access-key.secret}"
}

# Create user inline policy for s3 and firehose policies
resource "aws_iam_user_policy" "ate-user-policy-s3" {
  user   = "${aws_iam_user.ate-user.name}"
  name   = "${var.environment}-${var.project}-policy-s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.ate-s3-data.arn}/*",
        "${aws_s3_bucket.ate-s3-data.arn}"
      ]
    }
  ]
}
EOF
## Resource expectation: 
##   "arn:aws:s3:::prd-ate-data/*",
##   "arn:aws:s3:::prd-ate-data"
}

resource "aws_iam_user_policy" "ate-user-policy-firehose" {
  user   = "${aws_iam_user.ate-user.name}"
  name   = "${var.environment}-${var.project}-policy-firehose"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "firehose:PutRecordBatch",
      "Resource": [
        "${aws_kinesis_firehose_delivery_stream.ate-firehose-raw-logs.arn}",
        "${aws_kinesis_firehose_delivery_stream.ate-firehose-summary-logs.arn}"
      ] 
    }
  ]
}
EOF
## Resource expectation: 
##  "arn:aws:firehose:us-east-1:819895241319:deliverystream/prd-ate-raw-logs",
##  "arn:aws:firehose:us-east-1:819895241319:deliverystream/prd-ate-summary-logs"
}

# Create ATE role: glue and athena need this role
resource "aws_iam_role" "ate-role" {
  name = "${var.environment}-${var.project}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "firehose.amazonaws.com",
          "glue.amazonaws.com"
        ]
      }
    }
  ]
}
EOF
}

# Create role inline policy for s3 and firehose policies
resource "aws_iam_role_policy" "ate-role-policy-s3" {
  role = "${aws_iam_role.ate-role.id}"
  name = "${var.environment}-${var.project}-policy-s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.ate-s3-data.arn}/*",
        "${aws_s3_bucket.ate-s3-data.arn}"
      ]
    }
  ]
}
EOF
## Resource expectation: 
##   "arn:aws:s3:::prd-ate-data/*",
##   "arn:aws:s3:::prd-ate-data"
}
resource "aws_iam_role_policy" "ate-role-policy-firehose" {
  role = "${aws_iam_role.ate-role.id}"
  name = "${var.environment}-${var.project}-policy-firehose"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.ate-s3-data.arn}/*",
        "${aws_s3_bucket.ate-s3-data.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-1:819895241319:log-group:/aws/kinesisfirehose/prd-ate-raw-logs:log-stream:*",
        "arn:aws:logs:us-east-1:819895241319:log-group:/aws/kinesisfirehose/prd-ate-summary-logs:log-stream:*"
      ]
    }
  ]
}
EOF
## need correct log-stream arn
}

# Get default Glue role and attach to ATE role
data "aws_iam_policy" "aws-glue-service-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "ate-role-attachment" {
  role = "${aws_iam_role.ate-role.id}"
  policy_arn = "${data.aws_iam_policy.aws-glue-service-role.arn}"
}

# Get user for Redash and grant access to s3
data "aws_iam_user" "redash-athena-user" {
  user_name = "sw-prd-redash-athena"
}

resource "aws_iam_user_policy" "redash-athena-user-policy-s3" {
  user = "${data.aws_iam_user.redash-athena-user.user_name}"
  name = "${var.environment}-${var.project}-policy-s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.ate-s3-data.arn}/*",
        "${aws_s3_bucket.ate-s3-data.arn}"
      ]
    }
  ]
}
EOF
## Resource expectation: 
##   "arn:aws:s3:::prd-ate-data/*",
##   "arn:aws:s3:::prd-ate-data"
}
