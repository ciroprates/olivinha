variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "webhook_url" {
  description = "URL do webhook para notificação"
  type        = string
}

variable "n8n_instance_type" {
  description = "EC2 instance type for n8n (e.g., t2.micro, t3.micro)"
  type        = string
  default     = "t2.micro"
} 