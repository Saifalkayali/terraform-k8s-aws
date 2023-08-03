variable "aws_region" {
  description = "The AWS region to create the VPC in."
  default     = "us-west-2"
}


variable "vpc-cidr" {
  cidr_block = "172.168.0.0/16"
}

variable "pubsubcidr" {
  cidr_block = "172.168.0.0/24"
}

variable "prisubcidr" {
  cidr_block = "172.168.1.0/24"
}
