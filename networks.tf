########
# VPCs #
########

# Controller VPC
resource "aws_vpc" "vpc_controller" {
  provider             = aws.region-controller
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "controller-vpc-jenkins"
  }
}


################
# INTERNET GWs #
################

resource "aws_internet_gateway" "igw" {
  provider = aws.region-controller
  vpc_id   = aws_vpc.vpc_controller.id

}

###########
# AZ DATA #
###########

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-controller
  state    = "available"
}

###########
# SUBNETS #
###########
#Create subnet 1 em virginia
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-controller
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_controller.id
  cidr_block        = "10.0.1.0/24"

}

#Create subnet 2 em virginia
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-controller
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_controller.id
  cidr_block        = "10.0.2.0/24"

}

##################
# ROUTING TABLES #
##################

#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region-controller
  vpc_id   = aws_vpc.vpc_controller.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "controller-region-route-table"
  }
}

#Overwrite default route table of VPC(Controller) with our route table entries
resource "aws_main_route_table_association" "set-controller-default-rt-assoc" {
  provider       = aws.region-controller
  vpc_id         = aws_vpc.vpc_controller.id
  route_table_id = aws_route_table.internet_route.id
}
