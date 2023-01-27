variable "pj" {
  type        = string
  description = "PJ名"
}

variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "subnet-cidr" {
  type        = string
  description = "サブネットのCIDRのリスト"
}
