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

  tags = merge(local.common_tags, var.tags, {
    Name  = "${var.project_name}-${var.environment}-aws-vpc"
    Cloud = "aws"
  })
}

# AWS VPC Flow Logs for security monitoring
resource "aws_flow_log" "vpc_flow_logs" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main[0].id

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-vpc-flow-logs" })
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.project_name}-${var.environment}-flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs[0].arn

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-vpc-flow-logs" })

  depends_on = [aws_kms_key.logs]
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-flow-log-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      }
    ]
  })

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-flow-log-role" })
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-flow-log-"
  role        = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Effect = "Allow"
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
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, var.tags, {
    Name = "${var.project_name}-${var.environment}-aws-public-${count.index + 1}"
    Type = "Public"
  })
}

# AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.enable_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-igw" })
}

# AWS Route Table
resource "aws_route_table" "public" {
  count = var.enable_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-public-rt" })
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

  name_prefix = "${var.project_name}-${var.environment}-aws-web-"
  vpc_id      = aws_vpc.main[0].id
  description = "Security group for web servers with configurable ingress"

  # HTTP ingress
  dynamic "ingress" {
    for_each = var.allowed_http_cidrs
    content {
      description = "HTTP ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTPS ingress
  dynamic "ingress" {
    for_each = var.allowed_https_cidrs
    content {
      description = "HTTPS ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # SSH ingress (optional use case)
  dynamic "ingress" {
    for_each = var.allowed_ssh_cidrs
    content {
      description = "SSH ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-web-sg" })
}

# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "logs" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, var.tags, { Name = "${var.project_name}-${var.environment}-aws-logs-key" })
}

resource "aws_kms_alias" "logs" {
  count = var.enable_aws && var.enable_flow_logs ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}-aws-logs"
  target_key_id = aws_kms_key.logs[0].key_id
}
