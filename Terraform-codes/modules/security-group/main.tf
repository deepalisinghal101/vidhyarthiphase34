resource "aws_security_group" "kafka_sg" {

  name        = var.sg_name
  description = "Security Group for Kafka Automation Infrastructure"
  vpc_id      = var.vpc_id

  ingress {

    description = "SSH Access"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "Jenkins UI"

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "Kafka Broker"

    from_port = 9092
    to_port   = 9092
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "Kafka Controller"

    from_port = 9093
    to_port   = 9093
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    description = "Allow All Outbound"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name        = "kafka_sg"
    Project     = "Kafka-Automation"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Vashishtha"

  }
}
