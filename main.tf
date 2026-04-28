provider "aws" {
  region = "us-west-1"
}

resource "aws_security_group" "db_sg" {
  name = "rds-test-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SOLO testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "test_db" {
  identifier        = "test-db-gha"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = "postgres"
  password = "MySecurePass123!"

  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

output "db_endpoint" {
  value = aws_db_instance.test_db.address
}

output "db_port" {
  value = aws_db_instance.test_db.port
}