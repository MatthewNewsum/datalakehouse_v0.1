import boto3
import requests
import json
import os
 
def lambda_handler(event, context):
    api_url = "https://data.cityofchicago.org/resource/6iiy-9s97.json"
 
    bucket_name = "demo-lakehouse-raw-zone"
    folder_name = "cta-data"
    file_name = "ctarawdata.json"
 
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        data = response.json()
 
        # Serialize data to JSON format
        json_data = json.dumps(data, indent=2)
 
        # Save the data to S3
        s3 = boto3.client('s3')
        s3.put_object(Bucket=bucket_name, Key=f"{folder_name}/{file_name}", Body=json_data)
 
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Data saved to S3 successfully."})
        }
 
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from API: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error fetching data from API."})
        }
 
    except boto3.exceptions.Boto3Error as e:
        print(f"Error saving data to S3: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error saving data to S3."})
        }