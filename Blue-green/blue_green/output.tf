output "blue_asg_id" {
  description = "Blue autoscaling group id"
  value       =  module.blue1.asg_id
}

output "green_asg_id" {
  description = "Green autoscaling group id"
  value       =  module.green1.asg_id
}
