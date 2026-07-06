variable "project_name" {
  type        = string
  description = "Project name tag for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "ID of the target VPC to associate with the hosted zone"
}

variable "kafka_private_ips" {
  type        = list(string)
  description = "Private IPs of the Kafka broker EC2 instances"
}
