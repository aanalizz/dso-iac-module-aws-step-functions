provider "aws" {
  region = "us-east-1"
}

variables {
  create          = false
  cloud_provider  = "aws"
  app_name        = "cph"
  environment     = "sbx"
  resource_suffix = "test"
  correlative     = "01"
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

run "no_resource_creation_when_disabled" {

  command = apply

  assert {
    condition     = output.state_machine_id == null
    error_message = "Expected state_machine_id output to be null when create is false"
  }

  assert {
    condition     = output.state_machine_arn == null
    error_message = "Expected state_machine_arn output to be null when create is false"
  }

  assert {
    condition     = output.state_machine_name == null
    error_message = "Expected state_machine_name output to be null when create is false"
  }

  assert {
    condition     = output.state_machine_creation_date == null
    error_message = "Expected state_machine_creation_date output to be null when create is false"
  }

  assert {
    condition     = output.state_machine_status == null
    error_message = "Expected state_machine_status output to be null when create is false"
  }

  assert {
    condition     = output.state_machine_version_arn == null
    error_message = "Expected state_machine_version_arn output to be null when create is false"
  }
}