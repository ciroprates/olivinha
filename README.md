# s3-notifier

A Terraform-based infrastructure to deploy an AWS Lambda function that sends S3 event notifications to a webhook (n8n), with DNS managed by Route53 and an EC2 instance running n8n behind Caddy with HTTPS.

## Features
- **AWS Lambda**: Notifies a webhook when new objects are created in an S3 bucket.
- **n8n on EC2**: Workflow automation tool running in a Docker container, reverse-proxied by Caddy with automatic HTTPS.
- **Route53**: DNS management for custom domains (e.g., `n8n.olivinha.site`).
- **Terraform**: Infrastructure as code for reproducible deployments.

## Project Structure
```
.
├── lambda/                  # Lambda function code (Python)
│   └── notify_webhook.py
├── n8n_ec2.tf               # EC2 instance and security group for n8n
├── outputs.tf               # Terraform outputs (public IP, URLs, etc.)
├── provider.tf              # AWS provider configuration
├── route53.tf               # Route53 DNS zone and records
├── terraform.tfvars         # Variables (bucket name, webhook URL, etc.)
├── variables.tf             # Variable definitions
├── webhook_lambda.tf        # Lambda and S3 notification resources
└── ...
```

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- AWS account and credentials configured (`aws configure`)
- A registered domain (e.g., `olivinha.site`)
- (Optional) [n8n](https://n8n.io/) knowledge for workflow automation

## Usage

1. **Clone the repository**
   ```bash
   git clone https://github.com/ciroprates/olivinha.git
   cd olivinha
   ```

2. **Edit `terraform.tfvars`**
   - Set your S3 bucket name and webhook URL (will be updated to use your domain after deploy).

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan and apply the infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

5. **Update your domain registrar**
   - After `terraform apply`, copy the Route53 nameservers from the output.
   - Update your domain's nameservers to the AWS Route53 ones.
   - Wait for DNS propagation.

6. **Access n8n**
   - Go to `https://n8n.olivinha.site` (or your configured subdomain).

## Security
- The EC2 security group only opens necessary ports (22, 80, 443, 5678).
- Caddy provides automatic HTTPS via Let's Encrypt.
- Lambda and S3 permissions are managed via IAM roles.

## Customization
- Edit the Caddyfile in the EC2 user-data (in `n8n_ec2.tf`) to change domain or proxy rules.
- Adjust the Lambda Python code in `lambda/notify_webhook.py` as needed.

## License
MIT 