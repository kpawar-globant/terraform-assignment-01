output "instance_id" {
  value = aws_instance.tf-ec2.id
}

output "public_ip" {
  value = aws_instance.tf-ec2.public_ip
}

output "private_ip" {
  value = aws_instance.tf-ec2.private_ip
}