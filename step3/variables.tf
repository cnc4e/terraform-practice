variable "vpc-cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "subnet-cidrs" {
  type        = list(string)
  description = "サブネットのCIDRのリスト"
}

# variable "sg-allow-cidrs" {
#   type        = list(string)
#   description = "SGで許可するCIDRのリスト"
# }

variable "sg-ingress-rulus" {
  type = map(object({
    protocol = string
  }))
  description = "SGで許可するルールのオブジェクト"
}
