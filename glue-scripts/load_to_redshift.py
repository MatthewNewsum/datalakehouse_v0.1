import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Read from S3
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="nyc_taxi_raw",
    table_name="yellow_tripdata_2023_01"
)

# Write to processed zone in Parquet format
glueContext.write_dynamic_frame.from_options(
    frame=datasource,
    connection_type="s3",
    connection_options={
        "path": "s3://demo-lakehouse-processed-zone/taxi_data/"
    },
    format="parquet"
)

job.commit()