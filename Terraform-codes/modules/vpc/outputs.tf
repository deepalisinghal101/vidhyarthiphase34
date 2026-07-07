output "vpc_id" {
  value = aws_vpc.kafka_vpc.id
}

output "route_table_id" {
  value = aws_route_table.kafka_rt.id
}
