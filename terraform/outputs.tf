output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion host"
  value       = module.ec2.bastion_public_ip
}

output "jenkins_public_ip" {
  description = "The public IP of the Jenkins server"
  value       = module.ec2.jenkins_public_ip
}

output "kafka_broker_private_ips" {
  description = "The private IPs of the Kafka brokers"
  value       = module.ec2.kafka_private_ips
}

output "kafka_ui_public_ip" {
  description = "The public IP of the Kafka UI dashboard"
  value       = module.ec2.kafka_ui_public_ip
}

output "s3_bucket_name" {
  description = "The name of the state S3 bucket"
  value       = module.s3.bucket_name
}

output "private_zone_id" {
  description = "The ID of the private hosted zone"
  value       = module.route53.zone_id
}

output "private_zone_name" {
  description = "The domain name of the private hosted zone"
  value       = module.route53.zone_name
}

