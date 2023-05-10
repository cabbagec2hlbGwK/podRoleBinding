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
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = var.database_name
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = true
}

output "dn_endpoint" {
  value = aws_db_instance.default.endpoint

}
output "db_arn" {
  value = aws_db_instance.default.arn
}
