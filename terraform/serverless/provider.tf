terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ACG-Terraform-Labs-Teste"

    workspaces {
      name = "techchallenge-serverless"
    }
  }
}

provider "aws" {
  access_key = "AKIAYQNJS2XQZDINY77A"
  secret_key = "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"
  region     = "us-east-1"
}