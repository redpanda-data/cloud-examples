terraform {
  # The byovpc module uses terraform_data, a 1.4 builtin. Declared here too so a root module on an
  # older Terraform fails with a version message rather than an unsupported-resource-type error.
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
  ignore_tags {
    key_prefixes = var.ignore_tags
  }
}
