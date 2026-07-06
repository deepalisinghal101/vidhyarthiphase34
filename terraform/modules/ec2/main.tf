data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.bastion_instance_type
  subnet_id            = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name             = var.ssh_key_name
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name         = "${var.project_name}-bastion"
    Environment  = var.environment
    AnsibleGroup = "bastion"
  }
}

# Jenkins Server
resource "aws_instance" "jenkins" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.jenkins_instance_type
  subnet_id            = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_sg_id]
  key_name             = var.ssh_key_name
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name         = "${var.project_name}-jenkins"
    Environment  = var.environment
    AnsibleGroup = "jenkins"
  }
}

# Kafka Brokers
resource "aws_instance" "kafka" {
  count                = 3
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.kafka_instance_type
  subnet_id            = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.kafka_sg_id]
  key_name             = var.ssh_key_name
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name            = "${var.project_name}-kafka-${count.index + 1}"
    Environment     = var.environment
    AnsibleGroup    = "kafka_brokers"
    kafka_broker_id = tostring(count.index + 1)
  }
}

# Persistent EBS Storage for Kafka Brokers
resource "aws_ebs_volume" "kafka_data" {
  count             = 3
  availability_zone = aws_instance.kafka[count.index].availability_zone
  size              = 50
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "${var.project_name}-kafka-data-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_volume_attachment" "kafka_data_attach" {
  count       = 3
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.kafka_data[count.index].id
  instance_id = aws_instance.kafka[count.index].id
}

# Kafka UI Server
resource "aws_instance" "kafka_ui" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.kafka_ui_instance_type
  subnet_id            = var.public_subnet_ids[1]
  vpc_security_group_ids = [var.kafka_ui_sg_id]
  key_name             = var.ssh_key_name
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name         = "${var.project_name}-kafka-ui"
    Environment  = var.environment
    AnsibleGroup = "kafka_ui"
  }
}
