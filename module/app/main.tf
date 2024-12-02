resource "aws_instance" "component" {
  ami           = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }
  tags = {
    Name = var.component
  }
}
resource "null_resource" "provisioner"{
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.component.public_ip
      port     = 22
    }
    inline = [
           "sudo pip3.11 install ansible",
#            "sudo dnf install nginx -y",
#            "sudo systemctl start nginx"
      "ansible-pull -i localhost, -U https://github.com/pdevpos/learn-ansible.git expense.yml -e env=dev -e component_name=frontend"
    ]
  }
}
resource "aws_route53_record" "route53" {
  name              = "${var.env}-${var.component}"
  type              = "A"
  zone_id           = var.zone_id
  ttl               = 50
  records           = [aws_instance.component.private_ip]
}