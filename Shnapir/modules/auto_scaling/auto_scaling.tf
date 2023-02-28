variable "vpc_subnet_id" {}
variable "vpc_id" {}
variable "sg_id" {}

resource "aws_launch_template" "shnapir_launch_template" {
  name_prefix   = "Shnapir-Launch-Template"
  image_id      = "ami-09cd747c78a9add63" # replace with our working app AMI ID
  instance_type = "t2.micro"

  user_data = base64encode("echo 'Hello, World!' > /tmp/hello.txt")

  network_interfaces {
    device_index               = 0
    associate_public_ip_address = true
    security_groups             = [var.sg_id]
    subnet_id                   = var.vpc_subnet_id
  }
}

resource "aws_autoscaling_group" "shnapir_asg" {
  name = "Shnapir-ASG"
  launch_template {
    id      = aws_launch_template.shnapir_launch_template.id
    version = "$Latest"
  }
vpc_zone_identifier = [var.vpc_subnet_id]

  min_size = 2
  max_size = 4
}
