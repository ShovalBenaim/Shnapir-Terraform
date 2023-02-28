# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Use the VPC module
module "vpc" {
  source = "./modules/vpc"
}

# Use the sg module
module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.aws_vpc_shnapir_vpc_id
}
module "rds" {
  source = "./modules/rds"
  postgres_username = "ubuntu"
  postgres_password = "Aa123456"
  private_subnet_id = module.vpc.aws_subnet_shnapir_private_subnet_id
  public_subnet_id = module.vpc.aws_subnet_shnapir_public_subnet_id
  sg_id = module.sg.sg_shnapir_sg_id
}
# Output the VPC ID
output "vpc_id" {
  value = module.vpc.aws_vpc_shnapir_vpc_id
}

# Output the public subnet ID
output "public_subnet_id" {
  value = module.vpc.aws_subnet_shnapir_public_subnet_id
}

# Output the private subnet ID
output "private_subnet_id" {
  value = module.vpc.aws_subnet_shnapir_private_subnet_id
}

# Output the NAT Gateway ID
output "nat_gateway_id" {
  value = module.vpc.aws_nat_gateway_shnapir_nat_gateway_id
}

# Output the Internet Gateway ID
output "internet_gateway_id" {
  value = module.vpc.aws_internet_gateway_shnapir_igw_id
}