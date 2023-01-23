variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "subnet-cidrs" {
  type        = list(string)
  description = "サブネットのCIDRのリスト"
}

variable "type" {
  type        = string
  description = "EC2インスタンスのタイプ"
}