variable "port" {
  type = number
}

variable "public_cidrs" {
  default = ["172.30.0.0/24", "172.30.1.0/24", "172.30.2.0/24"]
}

variable "private_cidrs" {
  default = ["172.30.10.0/24", "172.30.11.0/24", "172.30.12.0/24"]
}

variable "zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1d"]
}
