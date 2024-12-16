provider "aws" {
  region  = "us-east-1"
  profile = "onitytest001"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "onitytest001"
}