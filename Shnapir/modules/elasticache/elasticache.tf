provider "aws" {
  region = "us-east-1"
}

variable "private_subnet_id" { }
variable "public_subnet_id" { }
variable "sg_id" { }

resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redisSubnet"
  subnet_ids = [var.public_subnet_id, var.private_subnet_id] 
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  family  = "redis7.x"
  name    = "redisParameterGroup"
}
resource "aws_elasticache_cluster" "redis" {
  cluster_id = "redis"
  engine     = "redis"
  node_type  = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = aws_elasticache_parameter_group.redis_parameter_group.name
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet.name
  engine_version = "7.x"
  port = 6379
  security_group_ids = [var.sg_id]
  availability_zone = "us-east-1a"
}