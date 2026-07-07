terraform {
  required_version = ">= 6.48.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "terrafrom-bucket-project" # Change this
    key            = "infrastructure/state.tfstate"
    region         = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}