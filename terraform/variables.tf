// App vars
variable "app_name" {
  description = "Name of the application"
  default     = "goodrx-api"
}

variable "app_port" {
  description = "App port to be served"
  default     = 80
}

variable "environment" {
  description = "App environment"
  default     = "demo"
}

// AWS vars
variable "aws_access_key" {
  description = "AWS access key (AWS_ACCESS_KEY_ID)."
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key (AWS_SECRET_ACCESS_KEY)."
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-2"
}

// Network vars
variable "availability_zones" {
  default     = ["eu-west-2a", "eu-west-2b"]
  description = "List of availability zones"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR for az1 public subnet"
  default     = "10.0.20.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR for az2 public subnet"
  default     = "10.0.21.0/24"
}

// Instance vars
variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "ssh_port" {
  description = "Port for SSH access"
  default     = 22
}

// Security
variable "allowed_ssh_ips" {
  description = "CIDR blocks allowed for SSH access"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

// Locals
locals {
  public_subnet_cidrs = ["${var.public_subnet_az1_cidr}", "${var.public_subnet_az2_cidr}"]
}
