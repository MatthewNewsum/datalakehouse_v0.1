# Glue Connection for Redshift
# Glue Connection for Redshift
resource "aws_glue_connection" "redshift_connection" {
  name = "redshift-connection"
  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.demo.endpoint}/${aws_redshift_cluster.demo.database_name}"
    USERNAME           = aws_redshift_cluster.demo.master_username
    PASSWORD           = aws_redshift_cluster.demo.master_password
  }

  physical_connection_requirements {
    availability_zone      = aws_subnet.main.availability_zone
    subnet_id             = aws_subnet.main.id
    security_group_id_list = [aws_security_group.redshift.id]  # Correct property name
  }
}

resource "aws_glue_job" "load_to_redshift" {
  name     = "load-to-redshift"
  role_arn = aws_iam_role.redshift_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${aws_s3_bucket.scripts.id}/load_to_redshift.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"     = "python"
    "--TempDir"          = "s3://${aws_s3_bucket.scripts.id}/temporary/"
    "--connection-name"  = aws_glue_connection.redshift_connection.name
    "--enable-metrics"   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--continuous-log-logGroup"          = "/aws-glue/jobs/load-to-redshift"
  }
}