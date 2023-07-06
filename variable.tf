#------------------------------------------------------------------------------------------------------------------------------------
# Declare Variable blocks for main.tf Resources
#------------------------------------------------------------------------------------------------------------------------------------
variable "env_code" {
  description = "Environment name for deployment of resources"
  default     = ""
}
variable "public_cidr" {
  description = "list of cidr ranges for public subnets"
  default     = []
}
variable "private_cidr" {
  description = "list of cidr ranges for private subnets"
  default     = []
}
variable "availability_zone" {
  description = "list of availability zones"
  default     = []
}
variable "vpc_cidr" {
  description = "Cidr range for Dev VPC"
  default     = []
}
