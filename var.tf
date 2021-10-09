variable "environment" {
  type        = string
  description = "The environment the resources are deployed to"
  default     = "dev"
}
variable "location" {
  type        = string
  description = "The location where the resources are deployed to"
  default     = "australiaeast"
}