terraform {
  backend "s3" {
    bucket         = "ianc-terraform-state"
    key            = "homework1/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "ianc-terraform-lock"
    encrypt        = true
  }
}
