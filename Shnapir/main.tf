# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Use the VPC module
module "vpc" {
  source = "./modules/vpc"
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
