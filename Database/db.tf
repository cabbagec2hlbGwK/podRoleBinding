terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}
output "zones" {
  value = data.aws_availability_zones.available
}
data "aws_availability_zones" "available" {
}



module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                 = "test-db"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "3.0.0"
#   name                                   = "vpc-db"
#   cidr                                   = "10.0.0.0/16"
#   azs                                    = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   database_subnets                       = ["10.0.21.0/24", "10.0.22.0/24"]
#   create_database_subnet_group           = true
#   create_database_subnet_route_table     = true
#   create_database_internet_gateway_route = true

#   enable_dns_hostnames = true
#   enable_dns_support   = true

# }
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [module.vpc1.public_subnets[0], module.vpc1.public_subnets[1]]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_security_group" "default" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc1.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_name                = var.database_name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
}

output "dn_endpoint" {
  value = aws_db_instance.default.endpoint

}
