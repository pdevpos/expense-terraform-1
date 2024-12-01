module "frontend"{
  source = "./module/app"
  env = var.env
  instance_type= var.instance_type
  component = "frontend"
  ssh_password = var.ssh_user
  ssh_user = var.ssh_password
  zone_id = var.zone_id
}