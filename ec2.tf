# Create AWS key pair
resource "aws_key_pair" "powerbi_key" {
  key_name   = "powerbi-gateway-key"
  public_key = tls_private_key.powerbi_key.public_key_openssh
}

# Generate private key
resource "tls_private_key" "powerbi_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Output private key for secure storage
output "private_key" {
  value     = tls_private_key.powerbi_key.private_key_pem
  sensitive = true
}

# EC2 for PowerBI Gateway
resource "aws_instance" "powerbi_gateway" {
  ami                    = "ami-05b4ded3ceb71e470"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.powerbi_key.key_name
  vpc_security_group_ids = [aws_security_group.powerbi_gateway.id]


metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # This enforces IMDSv2
  }
  
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
    tags = {
      Name = "PowerBI Gateway Root Volume"
    }
    delete_on_termination = true
  }
  tags = {
    Name = "PowerBI Gateway"
  }
}