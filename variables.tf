
variable "vpc_cidr" {
    description = "vpc cidr range"
  type = string
  default = "10.0.0.0/16"
  
}
variable "vpc_tag" {
    description = "vpc tag"
  type = string
  default = "awsclass"
  
}
