variable "subnets" {
  description = "Subnets IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "instance_type" {
  description = "Instance type for prd env"
}

variable "region" {
  description = "AWS region" 
}

variable "my_ip" {
  description = "Personal IP to allow access"
}

variable "hosted_zone"{
  description = "route 53 hosted zone"
}