resource "aws_instance" "resource" {
  ami = data.aws_ami.ami.image_id
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type = "persistent"
    }
  }
  instance_type = var.instance_type
  tags = {
    Name = "${var.env}-${var.component}"
  }
}

resource "null_resource" "provisioner"{
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.ssh_user
      password = var.ssh_password
      host     = aws_instance.resource.public_ip
    }
    inline = [
           "sudo pip3.11 install ansible"
#            "ansible-pull -i localhost, -U https://github.com/pdevpos/learn-ansible.git expense.yml -e env=${var.env} -e component_name=${var.component}"
    ]
  }
}
resource "aws_route53_record" "route53" {
  name              = "${var.env}-${var.component}"
  type              = "A"
  zone_id           = var.zone_id
  ttl               = 50
  records           = [aws_instance.resource.private_ip]
}