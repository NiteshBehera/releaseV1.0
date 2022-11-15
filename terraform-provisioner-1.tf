resource "aws_vpc" "test_vpc"{
	cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "IGW-test"{
	vpc_id = aws_vpc.test_vpc.id
}
variable "subnet_public"{
	description = "public subnet"
	default = ["10.0.10.0/24","10.0.20.0/24"]
	type = list
}
resource "aws_subnet" "public-test"{
	count = "${length(var.subnet_public)}"
	vpc_id = aws_vpc.test_vpc.id
	cidr_block = "${var.subnet_public[count.index]}"
}
resource "aws_route_table" "test_RT"{
	vpc_id = aws_vpc.test_vpc.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.IGW-test.id
		}
}
resource "aws_route_table_association" "public"{
	count = "${length(var.subnet_public)}"
	subnet_id = "${element(aws_subnet.public-test.*.id, count.index)}"
	route_table_id = aws_route_table.test_RT.id
}

resource "aws_instance" "test1"{
	ami		=	"ami-0fa49cc9dc8d62c84"
	instance_type = "t2.micro"
	key_name = "Terraform-Key"
	connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./Terraform-Key.pem")
    host     = self.public_ip
  }
 }
resource "aws_instance" "test2"{
	ami		=	"ami-0fa49cc9dc8d62c84"
	instance_type = "t2.micro"
	key_name = "Terraform-Key"
	connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./Terraform-Key.pem")
    host     = self.public_ip
}

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
	  "sudo amazon-linux-extras install -y nginx1",
	  "sudo systemctl -l enable nginx",
	  "sudo systemctl -l start nginx",
	  "sudo systemctl -l status nginx",
    ]
  }
}