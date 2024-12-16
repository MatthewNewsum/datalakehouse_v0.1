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

# Write to Redshift
glueContext.write_dynamic_frame.from_jdbc_conf(
    frame=datasource,
    catalog_connection="redshift-connection",
    connection_options={
        "dbtable": "public.taxi_data",
        "database": "dev"
    },
    redshift_tmp_dir="s3://demo-lakehouse-raw-zone/temporary/"
)

job.commit()