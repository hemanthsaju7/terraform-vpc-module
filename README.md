# terraform-vpc-module

A group of standard configuration files in a specific directory make up a Terraform module. Terraform module allows you to group resources together and reuse this group later, possibly many times.

Here is a simple document on how to use Terraform to build an AWS VPC along with private/public Subnet and Network Gateway's for the VPC. We will be making 1 VPC with 6 Subnets: 3 Private and 3 Public, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables

# datasource.tf
```
data "aws_availability_zones" "az" {
  state = "available"
}
```

# outputs.tf
```
output "myvpc" {
  value = aws_vpc.main.id
}

output "public1" {
  value = aws_subnet.public1.id
}

output "public2" {
  value = aws_subnet.public2.id
}

output "public3" {
  value = aws_subnet.public3.id
}

output "private1" {
  value = aws_subnet.private1.id
}
  
output "private2" {
  value = aws_subnet.private2.id
}
  
output "private3" {
  value = aws_subnet.private3.id
}
```

# variables.tf
```
variable "project_name" {
  default = "example"
}

variable "project_env" {
  default = "test"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "region" {
  default = "us-east-2"
}
```

# provider.tf
```
provider "aws" {
  region = var.region
}
```

# main.tf
```
###
#Creating VPC #
###

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project_name}-${var.project_env}",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# Creating internet gateway #
###

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project_name}-${var.project_env}",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# public subnet 1 #
###

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[0]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 0)
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}-${var.project_env}-public1",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# public subnet 2 #
###  
  
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[1]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 1)
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}-${var.project_env}-public2",
    project = var.project_name,
    env     = var.project_env
  }
}

###
# public subnet 3 #
###
  
resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[2]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 2)
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}-${var.project_env}-public3",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# private subnet 1 #
###  
  
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[0]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 3)
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project_name}-${var.project_env}-private1",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# private subnet 2 #
###

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[1]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 4)
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project_name}-${var.project_env}-private2",
    project = var.project_name,
    env     = var.project_env
  }
}

###
# private subnet 3 #
###  
  
resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[2]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 5)
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project_name}-${var.project_env}-private3",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# elastic ip for nat gateway #
###

resource "aws_eip" "ngw" {
  vpc = true
  tags = {
    Name    = "${var.project_name}-${var.project_env}-nat",
    project = var.project_name,
    env     = var.project_env
  }
}

###
# Creating nat gateway #
###
  
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public2.id
  tags = {
    Name    = "${var.project_name}-${var.project_env}",
    project = var.project_name,
    env     = var.project_env
   }
  
    depends_on = [aws_internet_gateway.igw]
}
  
###
# Creating public route table #
###
  
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
   }
  tags = {
    Name    = "${var.project_name}-${var.project_env}-public",
    project = var.project_name,
    env     = var.project_env
  }
}
  
###
# Creating private route table #
###

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
 }
  tags = {
    Name    = "${var.project_name}-${var.project_env}-private",
    project = var.project_name,
    env     = var.project_env
 }
}

###
# Public route table association #
###
  
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
  
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
  
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
  
###
# Private route table association #
###

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
  
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
  
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
```
