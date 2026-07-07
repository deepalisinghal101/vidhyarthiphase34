resource "aws_instance" "kafka_ec2" {

  ami           = var.ami
  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = var.subnet_id

  vpc_security_group_ids = [var.sg_id]

  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {

    Name        = var.instance_name
    Project     = "Kafka-Automation"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Purpose     = "Kafka-Broker"
    Owner       = "Vashishtha"

  }
}
