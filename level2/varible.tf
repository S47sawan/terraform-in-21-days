#------------------------------------------------------------------------------------------------------------------------------------
# Declare Variable blocks for main.tf Resources
#------------------------------------------------------------------------------------------------------------------------------------
variable "env_code" {
  description = "Environment name for deployment of resources"
  default     = ""
}
variable "instance-type" {
  description = "Type of instance used"
  default     = ""
}
variable "key-name" {
  description = "ssh key for the instance "
  default     = ""
}
