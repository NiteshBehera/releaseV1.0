resource "aws_instance" "web1"{
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