# Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH from anywhere (in demo, restrict in prod)"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Jenkins server security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins UI access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

# Kafka Security Group
resource "aws_security_group" "kafka" {
  name        = "${var.project_name}-kafka-sg"
  description = "Kafka cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Ansible SSH from Jenkins"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins.id]
  }

  ingress {
    description = "Kafka Inter-broker communication"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "KRaft Controller Quorum communication"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Kafka access from Jenkins node (for tests)"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins.id]
  }

  ingress {
    description     = "Kafka access from Kafka UI"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka_ui.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-kafka-sg"
    Environment = var.environment
  }
}

# Kafka UI Security Group
resource "aws_security_group" "kafka_ui" {
  name        = "${var.project_name}-kafka-ui-sg"
  description = "Kafka UI dashboard access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Web interface port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project_name}-kafka-ui-sg"
    Environment = var.environment
  }
}
