provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATMFNDBSYXKOQLRWT"
  secret_key = "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"
}

resource "aws_instance" "first_project" {
  depends_on = [
      aws_security_group.all_allow
    ]
  ami             = "ami-038b3df3312ddf25d"
  instance_type   = "t2.micro"
  user_data = "${file("user_data.sh")}"
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    "Name" = "terraform-project"
  }
}

resource "aws_security_group" "all_allow" {
  name        = "sgfirst"
  description = "Allow inbound traffic"
   tags = {
    "Name" = "vpc-sg"
  }
  
    ingress {
    description = "all tcp allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "all ssh allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all http allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
      "Name" = "vpc"
    }
  
}

resource "aws_subnet" "public_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = "10.0.0.0/24"
availability_zone_id = "use1-az1"

tags = {
  "Name" = "public-subnet"
}
}

resource "aws_subnet" "private_subnet" {
vpc_id = aws_vpc.vpc.id 
cidr_block = "10.0.1.0/24"
availability_zone_id = "use1-az2"

tags = {
  "Name" = "private-subnet"
} 
}

resource "aws_internet_gateway" "vpc_igw" {

vpc_id = aws_vpc.vpc.id

    tags = {
      "Name" = "vpc-igw"
    }
  
}

resource "aws_route_table" "vpc_route_table" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      "Name" = "vpc-route_table"
    }
  
}

resource "aws_route_table_association" "vpc-rta" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.vpc_route_table.id
  
}

output "result" {
    value = aws_security_group.all_allow.id
}

output "route_table_id" {
    value = aws_route_table.vpc_route_table.id
  
}