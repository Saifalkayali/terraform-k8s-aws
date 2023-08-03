resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  depends_on = [
    vpc.my-vpc,
    aws_internet_gateway.aws_eip.myEIP,
    aws_eip.myEIP,
    aws_nat_gateway.NAT-GW,


  ]
  tags = {
    Name = "AppServerInstance"
  }
}
