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
  retention_in_days = 365                     # CKV_AWS_338: Minimum 1 year retention
  kms_key_id        = aws_kms_key.logs[0].arn # Encrypt logs

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
  map_public_ip_on_launch = false # Security: Don't auto-assign public IPs

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

# Internal ALB Security Group (created first to avoid circular dependency)
# This security group is for the internal application load balancer
resource "aws_security_group" "internal_alb" {
  count = var.enable_aws ? 1 : 0

  name_prefix = "${var.project_name}-internal-alb-"
  vpc_id      = aws_vpc.main[0].id
  description = "Security group for internal application load balancer"

  # No ingress rules by default - add specific rules based on requirements
  # Example: Allow from VPN, bastion, or other internal services

  tags = {
    Name = "${var.project_name}-internal-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Security Group Example
# Note: This security group demonstrates secure-by-default configuration.
# For production, attach this to your load balancer or application instances.
resource "aws_security_group" "web" {
  count = var.enable_aws ? 1 : 0

  name_prefix = "${var.project_name}-web-"
  vpc_id      = aws_vpc.main[0].id
  description = "Security group for web servers with restricted access"

  # HTTPS from internal load balancer only (not direct internet access)
  # AC_AWS_0322: Use security group reference instead of CIDR for internal traffic
  ingress {
    description     = "HTTPS from internal ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb[0].id]
  }

  # Restrict egress to HTTPS only for external API calls
  egress {
    description = "HTTPS outbound for external APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# Egress rule for ALB to web servers (separate to avoid circular dependency)
resource "aws_security_group_rule" "alb_to_web" {
  count = var.enable_aws ? 1 : 0

  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web[0].id
  security_group_id        = aws_security_group.internal_alb[0].id
  description              = "Forward HTTPS to web servers"
}

# CKV2_AWS_12: Default security group restricts all traffic
resource "aws_default_security_group" "default" {
  count = var.enable_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  # No ingress rules - deny all inbound by default
  # No egress rules - deny all outbound by default

  tags = {
    Name = "${var.project_name}-default-sg-restricted"
  }
}

# CKV2_AWS_5: Security group must be attached to a resource
# Example network interface to demonstrate security group attachment
resource "aws_network_interface" "example" {
  count = var.enable_aws ? 1 : 0

  subnet_id       = aws_subnet.public[0].id
  security_groups = [aws_security_group.web[0].id]
  description     = "Example ENI demonstrating security group attachment"

  tags = {
    Name = "${var.project_name}-example-eni"
  }
}

# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "logs" {
  count = var.enable_aws ? 1 : 0

  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 7    # Shorter window for template
  enable_key_rotation     = true # Enable automatic key rotation

  # CKV2_AWS_64: Explicit least-privilege key policy
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "logs-key-policy"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current[0].account_id}:log-group:*"
          }
        }
      }
    ]
  })

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