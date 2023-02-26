provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "./modules/ec2"

  app_server_names = ["Application-Server-1", "Application-Server-2", "Application-Server-3"]
}

