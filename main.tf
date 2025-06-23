terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  # Backend configuration will be provided via backend.hcl file or -backend-config flag
  # This allows for environment-specific state management
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AudioExtraction"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  project_name = "audio-extraction"

  # Common tags
  common_tags = {
    Project     = "AudioExtraction"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
