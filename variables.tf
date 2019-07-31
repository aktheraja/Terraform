variable "vpc_name" {
  description = "The name of the VPC"
}

//variable "cidr_numeral" {
//  description = "The VPC CIDR numeral (10.x.0.0/16)"
//}
//

variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
}
variable "ami_key_pair_name" {
  default = "MyKP"
}
variable "ami" {

  default = "ami-07669fc90e6e6cc47"
}

variable "min_asg" {
  default = 2
}

variable "des_asg" {
  default = 3
}

variable "max_asg" {
  default = 5
}


variable "min_asg2" {
  default = 0
}

variable "des_asg2" {
  default = 0
}

variable "max_asg2" {
  default = 0
}