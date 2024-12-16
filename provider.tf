terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify your desired version
    }
  }
}

provider "aws" {
  profile = "onitytest001"
  region  = "us-east-1"
}