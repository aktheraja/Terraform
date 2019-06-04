variable "max_size" {
  description = "The maximum size of the auto scale group"
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
}
variable "color" {
  description = "Color of the Auto Scaling Group"
}

variable "name" {
  description = "Name of the Auto Scaling Group"
}