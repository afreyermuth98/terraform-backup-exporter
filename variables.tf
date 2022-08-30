variable "runtime" {
  type        = string
  default     = "python3.8"
  description = "The identifier of the lambda function's runtime"
}

variable "memory_size" {
  type        = string
  default     = "4096"
  description = "define default memory used by lambda"
}

variable "timeout" {
  type        = string
  default     = "60"
  description = "define default lambda timeout"
}

variable "region" {
  type        = string
  default     = "eu-west-3"
  description = "define default lambda region"
}

variable "subscriber_email" {
  type        = string
  description = "Default subscrier for SNS topic"
}

variable "days_to_retrieve" {
  type        = string
  default     = "30"
  description = "Default number of days to retrieve in backup query"
}

variable "lambda_schedule" {
  type        = bool
  default     = false
  description = "A boolean to schedule or not the lambda"
}

variable "s3_versioning_status" {
  type        = bool
  default     = true
  description = "A boolean to enable or not versioning on bucket"
}