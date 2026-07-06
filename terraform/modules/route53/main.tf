resource "aws_route53_zone" "private" {
  name = "kafka.internal"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name        = "${var.project_name}-private-zone"
    Environment = var.environment
  }
}

resource "aws_route53_record" "kafka_brokers" {
  count   = length(var.kafka_private_ips)
  zone_id = aws_route53_zone.private.zone_id
  name    = "broker${count.index + 1}.kafka.internal"
  type    = "A"
  ttl     = "300"
  records = [var.kafka_private_ips[count.index]]
}
