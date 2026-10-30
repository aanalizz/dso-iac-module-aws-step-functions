variable "cloud_provider" {
  description = "cloud provider"
  type        = string
}
variable "app_name" {
  description = "application name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}
variable "resource_suffix" {
  description = "resource suffix"
  type        = string
}
variable "correlative" {
  description = "correlative"
  type        = string
}
############################################
# Step Function - General settings - Controls whether resources should be created and other common settings
############################################
variable "create" {
  description = "Whether to create Step Function resource"
  type        = bool
  default     = true
}

variable "use_existing_cloudwatch_log_group" {
  description = "Whether to use an existing CloudWatch log group or create new"
  type        = bool
  default     = false
}

################
# Step Function
################

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to use for this Step Function"
  type        = string
  default     = ""
}

variable "type" {
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD. Valid Values: STANDARD | EXPRESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], upper(var.type))
    error_message = "Step Function type must be one of the following (STANDARD | EXPRESS)."
  }
}

variable "sfn_state_machine_timeouts" {
  description = "Create, update, and delete timeout configurations for the step function."
  type        = map(string)
  default     = {}
}

variable "publish" {
  description = "Determines whether to set a version of the state machine when it is created."
  type        = bool
  default     = false
}

variable "encryption_configuration" {
  description = "Defines what encryption configuration is used to encrypt data in the State Machine."
  type        = any
  default     = {}
}
variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing for the Step Function"
  type        = bool
  default     = false
}
#################
# CloudWatch Logs
#################

variable "logging_configuration" {
  description = "Defines what execution history events are logged and where they are logged. Keys: level (ALL|ERROR|FATAL|OFF), include_execution_data (bool), log_destination (ARN)."
  type        = any
  default     = {}
}

variable "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch Logs group name to use."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}
variable "cloudwatch_logs_skip_destroy" {
  description = "Whether to keep the log group (and any logs it may contain) at destroy time."
  type        = bool
  default     = false
}