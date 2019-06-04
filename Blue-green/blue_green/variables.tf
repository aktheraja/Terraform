variable "name" {
  description = "Name of the Auto Scaling Groups"
  default = "blue_green_Auto_scale"
}

variable "blue_max_size" {
  description = "The maximum size of the blue autoscaling group"
  default = 5
}

variable "blue_min_size" {
  description = "The minimum size of the blue autoscaling group"
  default = 2
}

variable "blue_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the blue autoscaling roup"
  default = 4
}

variable "blue_instance_type" {
  description = "The Blue instance type to launch"
  default = "t2.nano"
}

variable "blue_ami" {
  description = "The EC2 image ID to launch in the Blue autoscaling group"
  default = "ami-14c5486b"
}

variable "green_max_size" {
  description = "The maximum size of the green autoscaling group"
  default = 0
}

variable "green_min_size" {
  description = "The minimum size of the green autoscaling group"
  default = 0
}

variable "green_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the green autoscaling roup"
  default = 0
}

variable "green_instance_type" {
  description = "The Green instance type to launch"
  default = "t2.nano"
}

variable "green_ami" {
  description = "The EC2 image ID to launch in the Green autoscaling group"
  default = "ami-14c5486b"
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  default     = ""
}


