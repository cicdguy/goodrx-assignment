output "alb_address" {
  description = "FQDN for the ALB"
  value       = "${module.alb.dns_name}"
}

output "instance_ip" {
  description = "Instance IP"
  value       = "${module.ec2.public_ip}"
}
