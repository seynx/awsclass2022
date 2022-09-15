#please do this lab for your testing

provider "aws" {
  region     = "us-east-1"
  profile = "put yours here"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}


resource "aws_security_group" "secgroup" {
  name        = "secgroup"
  description = "trafficc"
  vpc_id      = "vpc-inside-your-console"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_tls"
  }
}


resource "aws_instance" "firstec2" {
  ami               = "ami-copyfromconsole"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  key_name          = "your key"
  user_data         = file("script.sh")
  security_groups = [aws_security_group.secgroup.name]
  tags = {
    Name = "We are alive"
  }
}


################
# VARIABLES TEST#
################

 
resource "aws_vpc" "testvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = var.vpc_tag
  }
}



######################
#LAB
######################


#1. Create a VPC
resource "aws_vpc" "seynxvpc" {
  cidr_block = "10.0.0.0/16"
}
#2. Create Internet Gateway
resource "aws_internet_gateway" "seynxgw" {
  vpc_id = aws_vpc.seynxvpc.id

  tags = {
    Name = "seynxig"
  }
}
#3. Create Custom Route Table
resource "aws_route_table" "seynxrt" {
  vpc_id = aws_vpc.seynxvpc.id
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.seynxgw.id
    }
   route {
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.seynxgw.id
    }


  tags = {
    Name = "seynxrts"
  }
}
#4. Create a Subnet
resource "aws_subnet" "seynxsn" {
  vpc_id     = aws_vpc.seynxvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "seynxsbn"
  }
}
#5. Associate Subnet with Route Table
resource "aws_route_table_association" "seynxsrt" {
  subnet_id      = aws_subnet.seynxsn.id
  route_table_id = aws_route_table.seynxrt.id
}
#6. Create Security Group to allow port 22,80 and 443
resource "aws_security_group" "seynxsg" {
  name        = "web-traffic"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.seynxvpc.id

  ingress {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      
    }
  ingress {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }


  egress{
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }


  tags = {
    Name = "allow_tls"
  }
}
#7. Create a network interface with an ip in the subnet	that was created       in step 4

resource "aws_network_interface" "seynxint" {
  subnet_id       = aws_subnet.seynxsn.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.seynxsg.id]
}

#8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "seiynxel" {
  vpc                       = true
  network_interface         = aws_network_interface.seynxint.id
  associate_with_private_ip = "10.0.1.50"
}

#9. Create an instance
resource "aws_instance" "seynxfirst" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  network_interface {
  device_index = 0 #which interface to use first like ETHernet 1,2 etc
  network_interface_id = aws_network_interface.seynxint.id
}
user_data = file("script.sh")
  tags = {
    Name = "seynxins"
  }
}
