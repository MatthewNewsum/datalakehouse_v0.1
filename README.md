Collecting workspace information

Here's a README.md for your data lakehouse infrastructure project:

# AWS Data Lakehouse Infrastructure

This project implements a modern data lakehouse architecture on AWS using Terraform, consisting of S3 storage zones, Glue for ETL, and Athena for querying.

## Architecture

The infrastructure includes:

- 3 S3 storage zones:
  - Raw Zone (`demo-lakehouse-raw-zone`)
  - Processed Zone (`demo-lakehouse-processed-zone`) 
  - Curated Zone (`demo-lakehouse-curated-zone`)

- AWS Glue for ETL processing
  - Crawler configured for NYC taxi data
  - IAM role with S3 access permissions

- AWS Athena for querying
  - Dedicated workgroup
  - Query results stored in processed zone

## Storage Lifecycle Management

Automated lifecycle rules are configured:

- Raw zone: Files transition to INTELLIGENT_TIERING after 30 days, expire after 90 days
- Processed zone: Files transition to INTELLIGENT_TIERING after 60 days
- Versioning enabled on all buckets

## Monitoring

CloudWatch dashboard provides metrics for:
- Athena query execution times
- Cost monitoring

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.5.7 or later
- AWS account with permissions to create required resources

## Usage

Initialize Terraform:
```sh
terraform init
```

Apply the infrastructure:
```sh
terraform apply
```

## Note

This infrastructure is designed for a demo/development environment. For production use, consider:

- Enabling encryption at rest
- Configuring bucket policies
- Setting up cross-region replication
- Implementing additional security controls

## License

This project is licensed under the terms of the Mozilla Public License 2.0.


## Architecture Diagram

```mermaid
graph TD
    A[Raw Zone<br>S3 Bucket] --> C[Glue Crawler<br>ETL]
    C --> B[Processed Zone<br>S3 Bucket]
    B --> D[Athena<br>Querying]
    D --> E[Curated Zone<br>S3 Bucket]
    D --> F[CloudWatch<br>Dashboard]

    classDef storage fill:#f9f,stroke:#333,stroke-width:2px;
    classDef compute fill:#bbf,stroke:#333,stroke-width:2px;
    classDef monitoring fill:#bfb,stroke:#333,stroke-width:2px;
    
    class A,B,E storage;
    class C,D compute;
    class F monitoring;


## S3 Lifecycle Rules
- Raw → INTELLIGENT_TIERING (30d) → Expire (90d)
- Processed → INTELLIGENT_TIERING (60d)