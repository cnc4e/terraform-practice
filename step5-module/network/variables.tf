variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "subnet-cidrs" {
  type        = list(string)
  description = "サブネットのCIDRのリスト"
}
