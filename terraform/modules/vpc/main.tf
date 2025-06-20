# Use an existing VPC instead of creating a new one
data "aws_vpc" "existing" {
  id = "vpc-0dd081f902c8112b5"
}

# Public subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name                        = "public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/eks" = "shared"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks"       = "shared"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "eks-nat"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.existing.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Reference existing IGW and Public Route Table
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

data "aws_route_table" "existing_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# Associate public subnets to the existing Public Route Table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = data.aws_route_table.existing_public.id
}

# Private route table associations
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = data.aws_vpc.existing.id
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 30
}

resource "aws_iam_role" "flow_log" {
  name = "vpc-flow-log-role"

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
}

resource "aws_iam_role_policy" "flow_log" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.flow_log.arn
      }
    ]
  })
}

# Network ACL for private subnets to allow traffic from the public subnets
resource "aws_network_acl" "private" {
  vpc_id = data.aws_vpc.existing.id

  tags = {
    Name = "private-nacl"
  }
}

resource "aws_network_acl_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  network_acl_id = aws_network_acl.private.id
}

# Ingress from public subnets
resource "aws_network_acl_rule" "ingress_from_public_1" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public[0].cidr_block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "ingress_from_public_2" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 101
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public[1].cidr_block
  from_port      = 0
  to_port        = 0
}

# Egress to anywhere (for return traffic and internet access via NAT)
resource "aws_network_acl_rule" "egress_to_anywhere" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# VPC Endpoints for EKS
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = data.aws_vpc.existing.id
  service_name        = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = data.aws_vpc.existing.id
  service_name        = "com.amazonaws.us-east-1.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
}

resource "aws_vpc_endpoint" "elb" {
  vpc_id              = data.aws_vpc.existing.id
  service_name        = "com.amazonaws.us-east-1.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
} 