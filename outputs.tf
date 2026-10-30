# Step Function
output "state_machine_id" {
  description = "The ARN of the Step Function"
  value       = try(aws_sfn_state_machine.main.id, null)
}

output "state_machine_arn" {
  description = "The ARN of the Step Function"
  value       = try(aws_sfn_state_machine.main.arn, null)
}

output "state_machine_name" {
  description = "The Name of the Step Function"
  value       = try(aws_sfn_state_machine.main.name, null)
}

output "state_machine_creation_date" {
  description = "The date the Step Function was created"
  value       = try(aws_sfn_state_machine.main.creation_date, null)
}

output "state_machine_status" {
  description = "The current status of the Step Function"
  value       = try(aws_sfn_state_machine.main.status, null)
}

output "state_machine_version_arn" {
  description = "The ARN of state machine version"
  value       = try(aws_sfn_state_machine.main.state_machine_version_arn, null)
}