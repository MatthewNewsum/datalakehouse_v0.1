import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
from pyspark.sql import DataFrame
args = getResolvedOptions(sys.argv, ['source_bucket', 'destination_bucket'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
# Read from source
datasource = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={
        "paths": [f"s3://{args['source_bucket']}/nyc-taxi/"], 
        "recurse": True  
    },
    format="parquet" 
)
 
df = datasource.toDF()
temp_output_path = f"s3://{args['destination_bucket']}/temp_output/"
 
df.coalesce(1).write.mode("overwrite").parquet(temp_output_path)
 
s3_client = boto3.client('s3')
bucket_name = args['destination_bucket']
 
response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix="temp_output/")
for obj in response.get('Contents', []):
    if obj['Key'].endswith(".parquet"):  
        source_key = obj['Key']
        break
 
final_output_key = "nyc-taxi-processed/nyc-taxi-data.parquet"
 
s3_client.copy_object(
    Bucket=bucket_name,
    CopySource={'Bucket': bucket_name, 'Key': source_key},
    Key=final_output_key
)
 
# Delete the temporary files
s3_client.delete_object(Bucket=bucket_name, Key=source_key)
 
job.commit()