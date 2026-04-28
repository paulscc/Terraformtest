terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  description = "Security group para RDS"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "rds-security-group"
  }
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.rds_subnets[*].id

  tags = {
    Name = "RDS Subnet Group"
  }
}

# VPC para RDS
resource "aws_vpc" "rds_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rds-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "rds_igw" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Name = "rds-igw"
  }
}

# Route Table
resource "aws_route_table" "rds_rt" {
  vpc_id = aws_vpc.rds_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rds_igw.id
  }

  tags = {
    Name = "rds-route-table"
  }
}

# Subnets para RDS
resource "aws_subnet" "rds_subnets" {
  count             = 2
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(["us-west-1a", "us-west-1b"], count.index)

  tags = {
    Name = "rds-subnet-${count.index}"
  }
}

# Route Table Association
resource "aws_route_table_association" "rds_rta" {
  count          = 2
  subnet_id      = aws_subnet.rds_subnets[count.index].id
  route_table_id = aws_route_table.rds_rt.id
}

# Instancia RDS MySQL
resource "aws_db_instance" "rds_mysql" {
  identifier             = "mysql-instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  parameter_group_name   = "default.mysql8.0"

  tags = {
    Name = "MySQL-RDS-Instance"
  }
}
