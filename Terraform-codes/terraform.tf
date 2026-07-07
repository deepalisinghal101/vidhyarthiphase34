terraform {
  backend "s3" {

    bucket = "terraform-state-vashishtha"
    key    = "A5-Terraform/terraform.tfstate"
    region = "ap-south-1"

    dynamodb_table = "terraform-lock"

    encrypt = true
  }
}

module "vpc" {

  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "subnet" {

  source = "./modules/subnet"

  vpc_id = module.vpc.vpc_id

  route_table_id = module.vpc.route_table_id

  subnet_cidr = var.subnet_cidr

  subnet_name = var.subnet_name

  az = var.az
}

module "sg" {

  source = "./modules/security-group"

  vpc_id = module.vpc.vpc_id

  sg_name = var.sg_name
}

module "ec2" {

  source = "./modules/ec2"

  ami = var.ami

  instance_type = var.instance_type

  subnet_id = module.subnet.subnet_id

  sg_id = module.sg.sg_id

  instance_name = var.instance_name

  key_name = var.key_name
}
