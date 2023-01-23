variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "dev" {
  type        = bool
  description = "dev環境かどうか"
}

# variable "subnet-cidr" {
#   type        = string
#   description = "サブネットのCIDR"
# }

variable "subnet-cidrs" {
  type        = list(string)
  description = "サブネットのCIDRのリスト"
}
