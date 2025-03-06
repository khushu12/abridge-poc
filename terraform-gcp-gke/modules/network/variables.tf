variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
}

variable "private_subnet_1_name" {
  description = "Name of the first private subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR range for the first private subnet"
  type        = string
}

variable "private_subnet_2_name" {
  description = "Name of the second private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR range for the second private subnet"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}

variable "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  type        = string
}

variable "create_internet_gateway" {
  description = "Whether to create an internet gateway for the public subnet"
  type        = bool
  default     = true
}
