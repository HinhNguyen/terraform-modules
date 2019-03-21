# Create S3 bucket
resource "aws_s3_bucket" "ate-s3-data" {
  bucket = "${var.environment}-${var.project}-data"
  acl    = "private"

  tags   = "${var.common-tags}"
}

# Create firehose stream into S3 for raw log and summary log
## Note: create firehose by aws console will create automatically inline policy in firehose role (arn:aws:iam::315962882822:role/firehose_delivery_role).
## Review role for next firehose.
resource "aws_kinesis_firehose_delivery_stream" "ate-firehose-raw-logs" {
  name        = "${var.environment}-${var.project}-raw-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn    = "${aws_iam_role.ate-role.arn}"
    bucket_arn  = "${aws_s3_bucket.ate-s3-data.arn}"
    prefix      = "api-raw-logs/"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "ate-firehose-summary-logs" {
  name        = "${var.environment}-${var.project}-summary-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn    = "${aws_iam_role.ate-role.arn}"
    bucket_arn  = "${aws_s3_bucket.ate-s3-data.arn}"
    prefix      = "api-summary-logs/"
  }
}

# Create glue crawler and glue catalog database 
## Glue crawler get log from S3 (no-sql type) and put into glue catalog / athena (sql type)
resource "aws_glue_catalog_database" "ate-glue-catalog-logs" {
  name = "${var.environment}_${var.project}_logs"
}

resource "aws_glue_crawler" "ate-glue-crawler-summary-logs" {
  database_name = "${aws_glue_catalog_database.ate-glue-catalog-logs.name}"
  name          = "${var.environment}-${var.project}-summary-logs"
  role          = "${aws_iam_role.ate-role.arn}"

  s3_target {
    path = "s3://${aws_s3_bucket.ate-s3-data.bucket}/api-summary-logs"
  }
  schedule = "cron(0 0/1 * * ? *)"
}
