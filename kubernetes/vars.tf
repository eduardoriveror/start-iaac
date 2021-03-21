variable "kubernetes_version" {
  description = "kubernetes version"
}

variable "subnets" {
  description = "Subnets IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "instance_prd" {
  description = "Instance type for prd env"
}

variable "asg_max_size_prd" {
  description = "Max amount of instances for prd"
}

variable "instance_tst" {
  description = "Instance type for prd env"
}

variable "asg_max_size_tst" {
  description = "Max amount of instances for prd"
}

variable "region" {
  description = "AWS region"
}