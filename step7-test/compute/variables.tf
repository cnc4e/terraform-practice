variable "pj" {
  type        = string
  description = "PJ名"
}

variable "app" {
  type        = string
  description = "アプリケーション名"
}

variable "type" {
  type        = string
  description = "EC2のインスタンスタイプ"
}

variable "vpc-id" {
  type        = string
  description = "EC2をデプロイするVPCのID"
}

variable "subnet-id" {
  type        = string
  description = "EC2をデプロイするサブネットのID"
}

variable "allow-access-cidr" {
  type        = string
  description = "EC2にアクセスを許可するCIDR"
}

variable "allow-tcp-ports" {
  type        = list(string)
  description = "EC2にアクセスを許可するTCP PORT"
}