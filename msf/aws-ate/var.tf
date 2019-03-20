variable "environment" {
  description = "Define environment e.g prd, stg, dev, etc"
}

variable "project" {
  default = "ate"
  description = "Define defaut value for project"
}

variable "app-count" {
  description = "Number of app server"
}

variable "app-keypair" {
  description = "Keypair of app server"
}

variable "bastion-keypair" {
  description = "Keypair of bastion host"
}

variable "common-tags" {
  description = "Define common tags for project"
  type = "map"
}
