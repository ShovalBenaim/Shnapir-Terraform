resource "aws_instance" "app_server" {
  count = length(var.app_server_names)

  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t3.large"
  tags = {
    Name = var.app_server_names[count.index]
  }
}

