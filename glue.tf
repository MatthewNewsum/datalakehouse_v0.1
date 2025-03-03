# CTA Database
resource "aws_glue_catalog_database" "cta_database" {
  name = "cta_database"
}

# CTA Data Crawler
resource "aws_glue_crawler" "cta_crawler" {
  database_name = aws_glue_catalog_database.cta_database.name
  name          = "cta_crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path       = "s3://${aws_s3_bucket.processed_zone.id}/cta-data"
    exclusions = ["**.py", "**/_SUCCESS", "**/.DS_Store"]
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables     = { AddOrUpdateBehavior = "MergeNewColumns" }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
}

# Raw Zone Database
resource "aws_glue_catalog_database" "nyc_taxi" {
  name = "nyc_taxi_raw"
}

# Processed Zone Database
resource "aws_glue_catalog_database" "nyc_taxi_processed" {
  name = "nyc_taxi_processed"
}

# Raw Zone Crawler
resource "aws_glue_crawler" "raw_zone" {
  database_name = aws_glue_catalog_database.nyc_taxi.name
  name          = "raw-zone-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path       = "s3://${aws_s3_bucket.raw_zone.id}/nyc-taxi"
    exclusions = ["**.py", "**/_SUCCESS", "**/.DS_Store"]
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables     = { AddOrUpdateBehavior = "MergeNewColumns" }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
}

# Processed Zone Crawler
resource "aws_glue_crawler" "processed_zone" {
  database_name = aws_glue_catalog_database.nyc_taxi_processed.name
  name          = "processed-zone-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path       = "s3://${aws_s3_bucket.processed_zone.id}/nyc-taxi-processed"
    exclusions = ["**.py", "**/_SUCCESS", "**/.DS_Store"]
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables     = { AddOrUpdateBehavior = "MergeNewColumns" }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
}

# ETL Script Storage
data "local_file" "etl_script" {
  filename = "${path.module}/scripts/raw_to_processed.py"
}

resource "aws_s3_object" "glue_etl_script" {
  bucket  = aws_s3_bucket.raw_zone.id
  key     = "scripts/raw_to_processed.py"
  content = data.local_file.etl_script.content
  etag    = filemd5("${path.module}/scripts/raw_to_processed.py")
}

# Glue Job
resource "aws_glue_job" "raw_to_processed" {
  name     = "raw-to-processed-zone"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.raw_zone.id}/${aws_s3_object.glue_etl_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"              = "python"
    "--continuous-log-logGroup"   = "/aws-glue/jobs"
    "--enable-metrics"            = ""
    "--TempDir"                   = "s3://${aws_s3_bucket.raw_zone.id}/temporary/"
    "--source_bucket"             = aws_s3_bucket.raw_zone.id
    "--destination_bucket"        = aws_s3_bucket.processed_zone.id
    "--additional-python-modules" = "boto3==1.26.137"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

# Job Trigger
resource "aws_glue_trigger" "raw_to_processed_trigger" {
  name     = "raw-to-processed-trigger"
  type     = "SCHEDULED"
  schedule = "cron(0 0 * * ? *)" # Daily at midnight

  actions {
    job_name = aws_glue_job.raw_to_processed.name
  }
}