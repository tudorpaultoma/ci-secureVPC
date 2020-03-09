variable "project-name" {
  type        = string
  default     = "secureVPC"
  description = "The name of the Project"
}

variable "region" {
  type        = string
  default     = "eu-frankfurt"
  description = "The name of the region"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "The name of the environment"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "The CIDR block of the VPC"
}

variable "tag-owner" {
  type        = string
  default     = "tudortoma@tencent.com"
  description = "The info of the owner"
}

variable "tag-purpose" {
  type        = string
  default     = "governed Secure VPC deployment"
  description = "The purpose of the deployment"
}

variable "tag-security_lvl" {
  type        = string
  default     = "standard"
  description = "The security level of the deployment"
}

variable "tag-cost_center" {
  type        = string
  default     = "internal"
  description = "The ID or name of the cost center"
}

variable "multicast" {
  type        = string
  default     = "false"
  description = "The value for the multicast enablement"
}

variable "AZ-1" {
  type        = string
  default     = "1"
  description = "The value for the first availability zone"
}