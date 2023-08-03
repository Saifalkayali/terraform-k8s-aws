# Creating RT for Private Subnet

resource "aws_route_table" "privRT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW.id
  }
}

# Creating RT for Public Subnet
resource "aws_route_table" "publRT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}
#Associating the Public RT with the Public Subnets
resource "aws_route_table_association" "PubRTAss" {
  subnet_id      = aws_subnet.mypublicsubnet.id
  route_table_id = aws_route_table.publRT.id
}
#Associating the Private RT with the Private Subnets
resource "aws_route_table_association" "PriRTAss" {
  subnet_id      = aws_subnet.myprivatesubnet.id
  route_table_id = aws_route_table.privRT.id
}
