terraform {
  backend "s3" {
    bucket = "gortyy-tfstate"
    key    = "gortyy-serverless"
    region = "us-east-1"
  }
}
