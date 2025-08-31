# AWS-specific resources (conditional)

# Data sources for AWS
data "aws_availability_zones" "available" {
  count = var.enable_aws ? 1 : 0
  state = "available"
}

data "aws_caller_identity" "current" {
  count = var.enable_aws ? 1 : 0
}

# AWS VPC Configuration
resource "aws_vpc" "main" {
  count = var.enable_aws ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# AWS VPC Flow Logs for security monitoring
resource "aws_flow_log" "vpc_flow_logs" {
  count = var.enable_aws ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main[0].id

  tags = {
    Name = "${var.project_name}-vpc-flow-logs"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_aws ? 1 : 0

  name              = "/aws/vpc/${var.project_name}-flow-logs"
  retention_in_days = 7  # Keep costs low for template
  kms_key_id        = aws_kms_key.logs[0].arn  # Encrypt logs

  tags = {
    Name = "${var.project_name}-vpc-flow-logs"
  }

  depends_on = [aws_kms_key.logs]
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  count = var.enable_aws ? 1 : 0

  name_prefix = "${var.project_name}-flow-log-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-flow-log-role"
  }
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_aws ? 1 : 0

  name_prefix = "${var.project_name}-flow-log-"
  role        = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
      }
    ]
  })
}

# AWS Subnets
resource "aws_subnet" "public" {
  count = var.enable_aws ? min(length(data.aws_availability_zones.available[0].names), 2) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available[0].names[count.index]
  map_public_ip_on_launch = false  # Security: Don't auto-assign public IPs

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Type = "Public"
  }
}

# AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.enable_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# AWS Route Table
resource "aws_route_table" "public" {
  count = var.enable_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# AWS Route Table Associations
resource "aws_route_table_association" "public" {
  count = var.enable_aws ? length(aws_subnet.public) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# AWS Security Group Example
resource "aws_security_group" "web" {
  count = var.enable_aws ? 1 : 0

  name_prefix = "${var.project_name}-web-"
  vpc_id      = aws_vpc.main[0].id
  description = "Security group for web servers with restricted access"

  # Allow HTTP only from trusted networks (replace with your actual CIDR)
  ingress {
    description = "HTTP from trusted networks"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # Only allow from within VPC
  }

  # Allow HTTPS only from trusted networks
  ingress {
    description = "HTTPS from trusted networks"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # Only allow from within VPC
  }

  # Restrict egress to VPC only - add specific rules as needed
  # NOTE: For production, add specific egress rules for required services
  # Example: HTTPS to specific domains, database access, etc.
  egress {
    description = "Allow outbound within VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "logs" {
  count = var.enable_aws ? 1 : 0

  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 7  # Shorter window for template
  enable_key_rotation     = true  # Enable automatic key rotation

  tags = {
    Name = "${var.project_name}-logs-key"
  }
}

resource "aws_kms_alias" "logs" {
  count = var.enable_aws ? 1 : 0

  name          = "alias/${var.project_name}-logs"
  target_key_id = aws_kms_key.logs[0].key_id
}

# Add a NAT Gateway for secure outbound access (optional, costs money)
# Uncomment if you need secure outbound internet access
# resource "aws_eip" "nat" {
#   count = var.enable_aws ? 1 : 0
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-nat-eip"
#   }
# }
#
# resource "aws_nat_gateway" "main" {
#   count = var.enable_aws ? 1 : 0
#   allocation_id = aws_eip.nat[0].id
#   subnet_id     = aws_subnet.public[0].id
#   tags = {
#     Name = "${var.project_name}-nat-gw"
#   }
# }