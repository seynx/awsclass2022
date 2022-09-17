
variable "ingressrules" {
    type = list(number)
    default = [ 80, 443, 22 ]  
}

variable "egressrules" {
    type = list(number)
    default = [ 80, 443, 22, ]  
}

variable "vpc_cidr" {
    description = "vpc cidr range"
    type = string
    default = "10.0.0.0/16"  
}

variable "vpc_tag" {
    description = "vpc tag"
    type = string
    default = "vpc_a"  
}

variable "subnet_a" {
    description = "subnet 1"
    type = string
    default = "10.0.1.0/24"  
}

variable "subnet_tag" {
    description = "subnet name"
    type = string
    default = "public_subnet"  
}

variable "route_cidr" {
  description = "route cidr"
  type = string
  default = "0.0.0.0/0"
}

variable "private_ip" {
    description = "for network interface"
    type = string
    default = "10.0.1.20"  
}

variable "for_eip" {
    description = "mapping for eip"
    type = string
    default = "10.0.1.20"
  
}