# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    bucket         = "github-actions-terraform-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-terraform-lock"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
}

# Call the "bootstrap" "module to build our AWS seed info
# The items on the right are strings you can modify
# you will need a globally unique s3 bucket name
module "bootstrap" {
  source                      = "./modules/bootstrap"
  name_of_s3_bucket           = "github-actions-terraform-tfstate"
  dynamo_db_table_name        = "aws-terraform-lock"
  iam_user_name               = "GitHubActionsIamUser"
  ado_iam_role_name           = "GitHubActionsIamRole"
  aws_iam_policy_permits_name = "GitHubActionsIamPolicyPermits"
  aws_iam_policy_assume_name  = "GitHubActionsIamPolicyAssume"
}