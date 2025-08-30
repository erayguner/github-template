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

# AWS Subnets
resource "aws_subnet" "public" {
  count = var.enable_aws ? min(length(data.aws_availability_zones.available[0].names), 2) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available[0].names[count.index]
  map_public_ip_on_launch = true

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

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}