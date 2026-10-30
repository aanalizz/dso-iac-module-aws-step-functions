provider "aws" {
  region = "us-east-1"
}

mock_provider "aws" {}

variables {
  create          = false
  cloud_provider  = "aws"
  app_name        = "cph"
  environment     = "dev"
  resource_suffix = "sfn"
  correlative     = "01"
}

run "no_resource_creation_when_disabled" {

  command = plan

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