variable "type" {
  type        = string
  description = "EC2のインスタンスタイプ"
}

variable "subnet-id" {
  type        = string
  description = "EC2をデプロイするサブネットのID"
}
