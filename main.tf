locals {
    #l_tfenv_name = "packerbuild"
    l_tfenv_cidr = "10.1.0.0/23"
    l_tfenv_cidr_prefix = "10.1.0"
}

locals {
    l_tfenv_tags = "${map(
        "env", "packerbuild"
    )}"
}

data "aws_availability_zones" "aws_azs" {}

locals {
    aws_azs = "${data.aws_availability_zones.aws_azs.names}"
    aws_az1 = "${data.aws_availability_zones.aws_azs.names[0]}"
    aws_az2 = "${data.aws_availability_zones.aws_azs.names[1]}"
    aws_az3 = "${data.aws_availability_zones.aws_azs.names[2]}"
}

provider "aws" {
    region = "us-east-2"
    profile = "terraform"
}

resource "aws_vpc" "vpc" {
    cidr_block = "${local.l_tfenv_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "vpc"
            )
        )}"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "igw"
            )
        )}"   
}

resource "aws_route_table" "rt_pub" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "rt_pub"
            )
        )}"
}

resource "aws_route" "rt_pub_route_igw" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
    route_table_id = "${aws_route_table.rt_pub.id}"
}

resource "aws_subnet" "sn_pub_1" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${local.aws_az1}"
    cidr_block = "${local.l_tfenv_cidr_prefix}.0/28"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "sn_pub_1"
            )
        )}"    
}

resource "aws_subnet" "sn_pub_2" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${local.aws_az2}"
    cidr_block = "${local.l_tfenv_cidr_prefix}.16/28"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "sn_pub_2"
            )
        )}"    
}

resource "aws_subnet" "sn_pub_3" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${local.aws_az3}"
    cidr_block = "${local.l_tfenv_cidr_prefix}.32/28"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "sn_pub_3"
            )
        )}"    
}

resource "aws_security_group" "sg_pub_ssh" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = 
        "${merge(
            local.l_tfenv_tags,
            map(
                "Name", "sg_pub_ssh"
            )
        )}"    
}

resource "aws_security_group_rule" "sg_pub_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.sg_pub_ssh.id}"
    cidr_blocks = ["0.0.0.0/0"]
}