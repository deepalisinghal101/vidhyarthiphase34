resource "aws_vpc" "kafka_vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {

    Name        = var.vpc_name
    Project     = "Kafka-Automation"
    ManagedBy   = "Terraform"
    Environment = "Dev"

  }
}

resource "aws_internet_gateway" "kafka_igw" {

  vpc_id = aws_vpc.kafka_vpc.id

  tags = {
    Name = "kafka_igw"
  }
}

resource "aws_route_table" "kafka_rt" {

  vpc_id = aws_vpc.kafka_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.kafka_igw.id
  }

  tags = {
    Name = "kafka_rt"
  }
}
