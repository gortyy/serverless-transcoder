variable "region" {
  type = string
}

# IAM
variable "transcoder_role_name" {
  type = string
}

variable "transcoder_policy_name" {
  type = string
}

variable "transcode_video_lambda_role_name" {
  type = string
}

variable "cloudwatch_and_s3_lambda_policy_name" {
  type = string
}

variable "transcoder_lambda_policy_name" {
  type = string
}

variable "set_permisions_lambda_role_name" {
  type = string
}

# Lambda
variable "lambda_runtime" {
  type = string
}

variable "transcode_video_lambda_name" {
  type = string
}

variable "transcode_video_lambda_handler" {
  type = string
}

variable "set_permissions_lambda_name" {
  type = string
}

variable "set_permissions_lambda_handler" {
  type = string
}

variable "extract_metadata_lambda_name" {
  type = string
}

variable "extract_metadata_lambda_handler" {
  type = string
}

# SNS
variable "sns_emails" {
  type = string
}

# S3
variable "buckets" {
  type = list(string)
}

variable "buckets_mapper" {
  type = map(string)
}
