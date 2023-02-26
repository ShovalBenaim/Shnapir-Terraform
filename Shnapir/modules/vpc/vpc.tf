# Define the VPC
resource "aws_vpc" "shnapir_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Shnapir-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "shnapir_public_subnet" {
  vpc_id     = aws_vpc.shnapir_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Shnapir-Public-Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "shnapir_private_subnet" {
  vpc_id     = aws_vpc.shnapir_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Shnapir-Private-Subnet"
  }
}

# Define the Internet Gateway
resource "aws_internet_gateway" "shnapir_igw" {
  vpc_id = aws_vpc.shnapir_vpc.id

  tags = {
    Name = "Shnapir-Internet-Gateway"
  }
}

# Define the NAT Gateway
resource "aws_nat_gateway" "shnapir_nat_gateway" {
  allocation_id = aws_eip.shnapir_eip.id
  subnet_id     = aws_subnet.shnapir_public_subnet.id

  depends_on = [
    aws_internet_gateway.shnapir_igw,
  ]

  tags = {
    Name = "Shnapir-NAT-Gateway"
  }
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "shnapir_eip" {
  vpc = true

  tags = {
    Name = "Shnapir-Elastic-IP"
  }
}

# Output the VPC ID
output "aws_vpc_shnapir_vpc_id" {
  value = aws_vpc.shnapir_vpc.id
}

# Output the public subnet ID
output "aws_subnet_shnapir_public_subnet_id" {
  value = aws_subnet.shnapir_public_subnet.id
}

# Output the private subnet ID
output "aws_subnet_shnapir_private_subnet_id" {
  value = aws_subnet.shnapir_private_subnet.id
}

# Output the NAT Gateway ID
output "aws_nat_gateway_shnapir_nat_gateway_id" {
  value = aws_nat_gateway.shnapir_nat_gateway.id
}

# Output the Internet Gateway ID
output "aws_internet_gateway_shnapir_igw_id" {
  value = aws_internet_gateway.shnapir_igw.id
}
