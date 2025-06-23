output "bucket_name" {
  value = aws_s3_bucket.notifier.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.notifier.function_name
}

output "n8n_public_ip" {
  description = "Public IP of the n8n EC2 instance"
  value       = aws_instance.n8n.public_ip
}

output "n8n_security_group_id" {
  description = "Security Group ID for n8n EC2 instance"
  value       = aws_security_group.n8n_sg.id
}

output "route53_nameservers" {
  description = "Nameservers for olivinha.site domain"
  value       = aws_route53_zone.olivinha_site.name_servers
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID for olivinha.site"
  value       = aws_route53_zone.olivinha_site.zone_id
}

output "n8n_url" {
  description = "URL for n8n instance"
  value       = "https://n8n.olivinha.site"
} 