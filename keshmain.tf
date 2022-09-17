
provider "aws" {
    region = "us-east-1"
    profile = "iamadmin-general"  
}

resource "aws_instance" "webserver" {
    ami = "ami-05fa00d4c63e32376"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"    
    user_data = file("script.sh")
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.up.id
    }
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = var.vpc_tag
    } 
}

resource "aws_security_group" "publicSG" {
    name = "HTTP SSH"

    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "egress" {
        iterator = port
        for_each = var.egressrules
        content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
  
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_a

    tags = {
        Name = var.subnet_tag
    }  
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "MAINIGW"
    }
      
}

resource "aws_route_table" "route_a" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = var.route_cidr
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "table_a"
    }
  
}

resource "aws_route_table_association" "rtass" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.route_a.id  
}

resource "aws_network_interface" "up" {
    subnet_id = aws_subnet.main.id    
    security_groups = [aws_security_group.publicSG.id]
}

resource "aws_eip" "elasticip" {
    vpc = true
    network_interface = aws_network_interface.up.id
    associate_with_private_ip = var.for_eip 
}

output "EIP" {
    value = aws_eip.elasticip.public_ip
}

output "AMI" {
    value = aws_instance.webserver.ami
  
}