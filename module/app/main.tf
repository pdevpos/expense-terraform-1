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
      user     = var.ssh_user
      password = var.ssh_password
      host     = aws_instance.component.public_ip
      port     = 22
    }
    inline = [
           "sudo pip3.11 install ansible",
           "sudo dnf install nginx -y",
           "sudo systemctl start nginx"
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