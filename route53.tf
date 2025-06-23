# Route53 hosted zone for olivinha.site
resource "aws_route53_zone" "olivinha_site" {
  name = "olivinha.site"
}

# A record for n8n.olivinha.site pointing to the EC2 instance
resource "aws_route53_record" "n8n_olivinha_site" {
  zone_id = aws_route53_zone.olivinha_site.zone_id
  name    = "n8n.olivinha.site"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.n8n.public_ip]
}
