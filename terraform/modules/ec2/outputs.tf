# No outputs from this module 

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.runner.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.runner.public_ip
} 