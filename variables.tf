variable "app_name" {
  description = "application name"
  type        = string
}

variable "bucket_name" {
  description = "name of the bucket to used to upload the custom application"
  type        = string
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = true
}

variable "cdn_logging_bucket_name" {
  description = "bucket where the cloudfront logs will be send to"
  type        = string
}

variable "ssm_name_prefix" {
  description = "prefix for the ssm path for each custom application"
  type        = string
}

variable "tags" {
  description = "Map of custom tags for the provisioned resources"
  type        = map(string)
  default     = {}
}

variable "aws_account_id" {
  description = "aws account id used to build access policy for the cdn to s3"
  type        = string
}

variable "applications" {
  description = "map of custom applications to be setup"
  type = map(object({
    tags           = optional(map(string), {})
    application_id = string
    additional_ssm_parameters = optional(list(object({
      name  = string
      type  = optional(string, "SecureString") # String, StringList or SecureString
      value = string
    })), [])
  }))
}
