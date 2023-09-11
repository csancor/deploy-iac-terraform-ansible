variable "profile" {
  type    = string
  default = "default"
}

variable "region-controller" {
  type    = string
  default = "us-east-1"
}

variable "webserver-port" {
  type    = number
  default = 8080
}

variable "external-ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}

variable "dns-name" {
  type    = string
  default = "<public-hosted-zone-terminada-com-ponto>" # ex: "mydnslab1234.info."
}
