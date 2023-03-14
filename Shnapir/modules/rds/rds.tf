provider "aws" {
  region = "us-east-1"
}
#variable "postgres_username" { }
#variable "postgres_password" { }
variable "public_subnet_id" { }
variable "private_subnet_id" { }
variable "sg_id" { }

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "postgres_subnet" {
  name = "postgres-subnet-group"
  subnet_ids = [var.public_subnet_id, var.private_subnet_id]
  description = "postgres-subnet-group description"

  tags = {
    Name = "postgres-subnet-group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  engine                    = "postgres"
  engine_version            =  "14"
  multi_az                  = false
  identifier                = "postgres-instance"
  username                  = "ubuntu"
  password                  = random_password.password.result
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  db_subnet_group_name      = aws_db_subnet_group.postgres_subnet.name
  vpc_security_group_ids    = [var.sg_id]
  availability_zone         = "us-east-1a"
  db_name                   = "postgres"
  skip_final_snapshot       = true
}

output "postgres_password" {
  value = random_password.password.result
}