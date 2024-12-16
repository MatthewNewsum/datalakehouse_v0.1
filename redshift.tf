resource "aws_redshift_cluster" "demo" {
  cluster_identifier = "demo-lakehouse"
  database_name      = "dev"
  master_username    = "admin"
  master_password    = "Change-me!123"

  node_type       = "dc2.large"
  cluster_type    = "single-node"
  number_of_nodes = 1

  skip_final_snapshot                 = true
  automated_snapshot_retention_period = 7
  preferred_maintenance_window        = "sun:04:00-sun:05:00"

  # VPC Configuration
  cluster_subnet_group_name    = aws_redshift_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.redshift.id]
  
  tags = {
    Environment = var.environment
    Project     = "DataLakeHouse_Demo"
  }
}

resource "aws_redshift_subnet_group" "main" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.main.id]
}
