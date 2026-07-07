variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env_config" {
  type = map(object({
    vpc_cidr      = string
    subnet_cidr   = string
    instance_type = string
  }))
  default = {
    dev = {
      vpc_cidr      = "10.1.0.0/16"
      subnet_cidr   = "10.1.1.0/24"
      instance_type = "t3.micro"
    }
    test = {
      vpc_cidr      = "10.2.0.0/16"
      subnet_cidr   = "10.2.1.0/24"
      instance_type = "t3.micro"
    }
    prod = {
      vpc_cidr      = "10.3.0.0/16"
      subnet_cidr   = "10.3.1.0/24"
      instance_type = "t3.medium"
    }
  }
}