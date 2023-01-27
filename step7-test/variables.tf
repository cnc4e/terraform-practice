variable "pj" {
  type        = string
  description = "PJ名"
}

variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "type" {
  type        = string
  description = "EC2インスタンスのタイプ"
}

variable "subnet-cidr" {
  type        = string
  description = "サブネットのCIDRのリスト"
}

variable "allow-access-cidr" {
  type        = string
  description = "EC2にアクセスを許可するCIDR"
}

variable "allow-tcp-ports" {
  type        = list(string)
  description = "EC2にアクセスを許可するTCP PORT"
}
