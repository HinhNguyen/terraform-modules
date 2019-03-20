variable "environment" {
  description = "Define environment e.g prd, stg, dev, etc"
}

variable "project" {
  default = "ate"
  description = "Define defaut value for project"
}

variable "common-tags" {
  description = "Define common tags for project"
  default = {
    brand = "internal"
    project = "ate"
    owner = "nghinh@fossil.com"
    terraform_managed = "yes"
  }
}
