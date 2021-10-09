variable "environment" {
  type        = string
  description = "The environment the resources are deployed to"
  default     = "test"
}
variable "location" {
  type        = string
  description = "The location where the resources are deployed to"
  default     = "australiaeast"
}
