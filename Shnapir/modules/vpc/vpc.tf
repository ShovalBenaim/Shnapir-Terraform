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

# Define a public route table
resource "aws_route_table" "shnapir_public_rt" {
  vpc_id = aws_vpc.shnapir_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shnapir_igw.id
  }

  tags = {
    Name = "Shnapir-Public-RT"
  }
}

# Define a private route table
resource "aws_route_table" "shnapir_private_rt" {
  vpc_id = aws_vpc.shnapir_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.shnapir_nat_gateway.id
  }

  tags = {
    Name = "Shnapir-Private-RT"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "shnapir_public_rta" {
  subnet_id      = aws_subnet.shnapir_public_subnet.id
  route_table_id = aws_route_table.shnapir_public_rt.id
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "shnapir_private_rta" {
  subnet_id      = aws_subnet.shnapir_private_subnet.id
  route_table_id = aws_route_table.shnapir_private_rt.id
}

# Create a route to the Internet Gateway in the private route table via the NAT Gateway
resource "aws_route" "shnapir_nat_gateway_route" {
  route_table_id            = aws_route_table.shnapir_private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.shnapir_nat_gateway.id
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

resource "aws_route_table" "shnapir_private_route_table" {
  vpc_id = aws_vpc.shnapir_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.shnapir_nat_gateway.id
  }
}
