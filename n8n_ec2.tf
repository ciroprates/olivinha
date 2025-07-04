resource "aws_security_group" "n8n_sg" {
  name        = "n8n_sg"
  description = "Allow port 5678 for n8n and 443 for HTTPS"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "n8n" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.n8n_instance_type
  key_name      = "n8n-key"
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]
  
  # Configuração de CPU credits para t3
  credit_specification {
    cpu_credits = "unlimited"
  }
  
  tags = {
    Name = "n8n-server"
    Environment = "production"
    CostCenter = "n8n-automation"
  }
  user_data = <<-EOF
    #!/bin/bash
    
    # Configurar Swap (2GB)
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    # Configurar parâmetros do Swap
    echo "vm.swappiness=10" | tee -a /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf
    sysctl -p
    
    # Instalar dependências
    apt-get update -y
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
    
    # Instalar Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl start docker
    systemctl enable docker
    
    # Configurar limites de memória do Docker
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<'DOCKERCONF'
    {
      "default-memory-swap": "1G",
      "default-memory": "512m"
    }
    DOCKERCONF
    systemctl restart docker
    
    # Criar volume e iniciar n8n
    docker volume create n8n_data
    docker run -d --name n8n \
      -p 127.0.0.1:5678:5678 \
      -v n8n_data:/home/node/.n8n \
      --memory="512m" \
      --memory-swap="1g" \
      docker.n8n.io/n8nio/n8n
    
    # Instalar Caddy
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update -y
    apt-get install -y caddy
    
    # Configure Caddy
    cat > /etc/caddy/Caddyfile << 'CADDYFILE'
    n8n.olivinha.site {
      reverse_proxy localhost:5678
    }
    
    olivinha.site {
      redir https://n8n.olivinha.site{uri} permanent
    }
    
    www.olivinha.site {
      redir https://n8n.olivinha.site{uri} permanent
    }
    CADDYFILE
    systemctl enable caddy
    systemctl start caddy
  EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_default_vpc" "default" {} 