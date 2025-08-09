variable "my_ip" {
  description = "Your public IP address for SSH/Jenkins access"
    type        = string
    default     = "0.0.0.0/0"
}
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tfstate_bucket" {
  description = "S3 bucket to store terraform state (must exist or be created by bootstrap)"
  type        = string
}

variable "tfstate_lock_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "cluster_name" {
  type    = string
  default = "web-game-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.26"
}

variable "node_type" {
  type    = string
  default = "t3.medium"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_max" {
  type    = number
  default = 3
}

variable "ecr_repo_name" {
  type    = string
  default = "eks-web-game-java"
}
