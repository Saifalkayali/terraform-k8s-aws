provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "saif_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "saif Custom VPC"
  }
}

resource "aws_subnet" "saif_public_subnet" {
  vpc_id            = aws_vpc.saif_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "saif Public Subnet"
  }
}

resource "aws_subnet" "saif_private_subnet" {
  vpc_id            = aws_vpc.saif_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "saif Private Subnet"
  }
}

resource "aws_internet_gateway" "saif_ig" {
  vpc_id = aws_vpc.saif_custom_vpc.id

  tags = {
    Name = "saif Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.saif_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.saif_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.saif_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.saif_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.saif_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EIP for the IGW
resource "aws_eip" "myEIP" {
  vpc = true
}


resource "aws_instance" "web_instance" {
  ami           = "ami-0533f2ba8a1995cf9"
  instance_type = "t2.nano"
  key_name      = "MyKeyPair"

  subnet_id                   = aws_subnet.saif_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex

  amazon-linux-extras install nginx1 -y
  echo "<h1>$(curl https://api.saif.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "saif"
  }
}
