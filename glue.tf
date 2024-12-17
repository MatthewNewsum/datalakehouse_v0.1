resource "aws_glue_catalog_database" "nyc_taxi" {
  name = "nyc_taxi_raw"
}

resource "aws_glue_crawler" "raw_zone" {
  database_name = aws_glue_catalog_database.nyc_taxi.name
  name          = "raw-zone-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.raw_zone.id}/nyc-taxi"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}