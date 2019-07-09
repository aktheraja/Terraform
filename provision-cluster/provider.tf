# Setup our aws provider
provider "aws" {
  version = "~> 2.0"
//  access_key  = var.aws_access_key_id
//  secret_key  = var.aws_secret_access_key
  region      =  "us-west-2"
}
