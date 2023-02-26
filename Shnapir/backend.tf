terraform {
  backend "s3" {
    bucket         = "shnapir-tfstate-file"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
