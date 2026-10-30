provider "aws" {
  region = "us-east-1"
}

variables {
  create          = true
  cloud_provider  = "aws"
  app_name        = "cph"
  environment     = "sbx"
  resource_suffix = "test"
  role_arn        = "arn:aws:iam::123456789012:role/my-sfn-role"
  definition = <<-JSON
    {
      "Comment": "Test",
      "StartAt": "HelloWorld",
      "States": {
        "HelloWorld": {
          "Type": "Pass",
          "End": true
        }
      }
    }
  JSON
}

run "basic_sfn_creation" {

  command = apply

  variables {
    correlative = uuid()
  }

  assert {
    condition     = output.state_machine_id != ""
    error_message = "Expected state_machine_id output to be populated after apply"
  }

  assert {
    condition     = output.state_machine_arn != ""
    error_message = "Expected state_machine_arn output to be populated after apply"
  }

  assert {
    condition     = output.state_machine_name != ""
    error_message = "Expected state_machine_name output to be populated after apply"
  }
}

run "sfn_type_express" {

  command = apply

  variables {
    correlative = uuid()
    type        = "EXPRESS"
  }

  assert {
    condition     = output.state_machine_arn != ""
    error_message = "Expected state_machine_arn output to be populated when type is set to EXPRESS"
  }
}

run "sfn_with_cloudwatch_logging" {

  command = apply

  variables {
    correlative = uuid()
    logging_configuration = {
      level                  = "ALL"
      include_execution_data = true
    }
    use_existing_cloudwatch_log_group      = false
    cloudwatch_log_group_retention_in_days = 30
  }

  assert {
    condition     = output.state_machine_arn != ""
    error_message = "Expected state_machine_arn output to be populated when logging is enabled"
  }
}