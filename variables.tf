variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "prod_zone" {
  type    = string
  default = "us-central1-a"
}

variable "maintenance_zone" {
  type    = string
  default = "us-central1-b"
}

variable "prod_weight" {
  type = number
}

variable "maintenance_weight" {
  type = number
}