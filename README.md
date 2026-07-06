# AWS DevOps Infrastructure with Terraform, Ansible, Jenkins, and Kafka (KRaft)

This repository contains the complete Infrastructure-as-Code (IaC), configuration management playbooks, and CI/CD pipelines to deploy an enterprise-grade AWS environment hosting a multi-node Apache Kafka cluster operating in KRaft mode with dynamic DNS resolution via Route 53.

---

## Repository Structure

- `terraform/`: Contains modules to provision VPC, Subnets, Routing Tables, NAT Gateways, Security Groups, IAM Roles, S3 Buckets, Route 53 private hosted zone, and EC2 instances (Bastion, Jenkins, Kafka brokers, Kafka UI).
- `ansible/`: Configuration management to provision Kafka brokers in KRaft mode, format and mount EBS storage, set up systemd services, and deploy Kafka UI via Docker-Compose.
- `Jenkinsfile`: Comprehensive Jenkins CI/CD pipeline definition covering code style checks, security audits, Terraform execution stages, and dynamic inventory playbook runs.

---

## Dynamic Inventory & Route 53 DNS

Instead of managing static files with hardcoded IP addresses, this setup uses the **Ansible `aws_ec2` dynamic inventory plugin** and **AWS Route 53 Private Hosted Zones**.

### How it works:
1. **Route 53 Hosted Zone**:
   The Route 53 module creates a private zone `kafka.internal` associated with the VPC. It creates records:
   - `broker1.kafka.internal` -> Broker 1 Private IP
   - `broker2.kafka.internal` -> Broker 2 Private IP
   - `broker3.kafka.internal` -> Broker 3 Private IP

2. **Ansible Discovery**:
   The inventory is configured in `ansible/inventory/aws_ec2.yml`. When running a playbook, Ansible filters instances and overrides the `ansible_host` variable:
   - **For Kafka Brokers**: `ansible_host` resolves to `broker{{ tags.kafka_broker_id }}.kafka.internal`
   - **For other instances**: `ansible_host` defaults to public or private IP.

3. **Dynamic Quorum & Bootstrap Configuration**:
   - **Kafka Voters**: Quorum strings are constructed dynamically inside `server.properties.j2` by looping over the discovered `kafka_brokers` group:
     ```jinja2
     controller.quorum.voters={% for host in groups['kafka_brokers'] %}{{ hostvars[host]['broker_id'] }}@{{ hostvars[host]['ansible_host'] }}:9093{% if not loop.last %},{% endif %}{% endfor %}
     ```
     This resolves to `1@broker1.kafka.internal:9093,2@broker2.kafka.internal:9093,3@broker3.kafka.internal:9093`.
   - **Kafka UI Bootstrap Servers**: Generated dynamically inside `docker-compose.yml.j2`:
     ```jinja2
     - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS={% for host in groups['kafka_brokers'] %}{{ hostvars[host]['ansible_host'] }}:9092{% if not loop.last %},{% endif %}{% endfor %}
     ```
     This resolves to `broker1.kafka.internal:9092,broker2.kafka.internal:9092,broker3.kafka.internal:9092`.
   - **Proxy SSH Tunneling**: The ProxyCommand tunnels traffic through the first instance resolved in the `bastion` group dynamically:
     ```yaml
     ansible_ssh_common_args: '-o ProxyCommand="ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no -W %h:%p -q ubuntu@{{ hostvars[groups[\'bastion\'][0]][\'ansible_host\'] }}"'
     ```

---

## AWS Network & Security Architecture

### Subnet Layout
1. **Public Subnets**:
   - **Public Subnet A** (AZ A): Houses the Bastion host (for administrative access) and the Jenkins CI/CD controller.
   - **Public Subnet B** (AZ B): Houses the Kafka UI dashboard.
2. **Private Subnets**:
   - **Private Subnets A, B, and C** (spread across AZ A, B, and C): Host Kafka Brokers 1, 2, and 3 respectively. Brokers have no public IP addresses and communicate entirely on private IP routes.

---

## Step-by-Step Deployment Guide

### Prerequisites
1. **AWS Credentials**: Ensure your local or agent workspace has `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exported with privileges to create VPC, EC2, IAM, S3, and Route 53 resources.
2. **SSH Keys**: Create an EC2 key pair named `devops-key` in your target AWS region, and save the private key (`devops-key.pem`) locally.
3. **Jenkins Settings**: Ensure Jenkins has:
   - Jenkins plugins installed: `Pipeline`, `SonarQube Scanner`, `OWASP Dependency-Check Linker`, `Ansible Plugin`, `Slack Notification`.
   - Credentials configured:
     - SSH key file credentials named `ssh-key-for-instances` containing the private key.
     - AWS credentials binding named `aws-deployer-credentials`.

### Local Execution (Manual Deployment Option)
If you want to run this manually without Jenkins, run the following steps:

#### 1. Provision Infrastructure via Terraform
```bash
cd terraform
# Initialize and fetch providers
terraform init

# Check formatting and validate code correctness
terraform fmt -check
terraform validate

# Plan and preview AWS changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

#### 2. Configure Instances via Ansible Dynamic Inventory
Ensure you have the `amazon.aws` collection installed locally:
```bash
ansible-galaxy collection install amazon.aws
```

Run the Ansible playbook pointing to the dynamic inventory file:
```bash
cd ansible
# Verify connection to all discovered EC2 nodes
ansible-inventory -i inventory/aws_ec2.yml --graph

# Run the master playbook to configure Java, Kafka KRaft, and Kafka UI
ansible-playbook -i inventory/aws_ec2.yml playbooks/site.yml
```

---

## Production Best Practices & HA Recommendations

### 1. High Availability (HA) & Internal Routing
- **DNS Resolution**: Using DNS hostnames (Route 53) instead of raw IPs ensures that clients and other brokers do not require re-configuration if a node is replaced and its IP changes.
- **Multi-AZ Spread**: Kafka brokers must be spread across separate physical AWS availability zones (represented in this blueprint's subnets mapping to AZs A, B, and C).
- **Replication Settings**: For critical metadata and data topics, a replication factor of `3` is mandatory (`default.replication.factor=3`).
- **Minimum In-Sync Replicas (min.insync.replicas)**: Set to `2` to guarantee write durability. Producers should write with `acks=all` so that writes are acknowledged by at least two brokers.
