# Require TF version to be same as or greater than 0.12.13
terraform {
  # required_version = ">=0.12.13"
  backend "s3" {
    bucket         = "github-actions-terraform-tfstate-x123"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-terraform-lock"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  # version = "~> 2.36.0"
  # version 3.74 to address issue https://github.com/hashicorp/terraform-provider-aws/issues/23106
  version = "~> 3.74"
}

##
#Below are sample resources to have terraform provision
##

# Always call the seed_module so state and lock are consistant
module "seed" {
  source                      = "./modules/seed"
  name_of_s3_bucket           = "github-actions-terraform-tfstate-x123"
  dynamo_db_table_name        = "aws-terraform-lock"
  iam_user_name               = "GitHubActionsIamUser"
  ado_iam_role_name           = "GitHubActionsIamRole"
  aws_iam_policy_permits_name = "GitHubActionsIamPolicyPermits"
  aws_iam_policy_assume_name  = "GitHubActionsIamPolicyAssume"
}

# Additional and optional resources to be provisioned

# Build the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name      = "Vpc"
    Terraform = "true"
  }
}

# Build route table 1
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable1"
    Terraform = "true"
  }
}

# Build route table 2
resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable2"
    Terraform = "true"
  }
}
