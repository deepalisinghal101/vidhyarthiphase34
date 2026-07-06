variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name tag for resource naming"
  type        = string
  default     = "devops-kafka"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "bastion_instance_type" {
  description = "EC2 Instance type for Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "jenkins_instance_type" {
  description = "EC2 Instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "kafka_instance_type" {
  description = "EC2 Instance type for Kafka brokers"
  type        = string
  default     = "t3.medium"
}

variable "kafka_ui_instance_type" {
  description = "EC2 Instance type for Kafka UI"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Name of the AWS EC2 SSH key pair"
  type        = string
  default     = "devops-key"
}
