provider "aws" {
  region = "us-east-1"
}

mock_provider "aws" {}

variables {
  create          = true
  cloud_provider  = "aws"
  app_name        = "cph"
  environment     = "dev"
  resource_suffix = "sfn"
  correlative     = "01"
  role_arn        = "arn:aws:iam::123456789012:role/dummy-role"
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

  command = plan

  assert {
    condition     = aws_sfn_state_machine.main.type == "STANDARD"
    error_message = "Expected Step Function type to be STANDARD by default when type variable is not specified"
  }
}

run "sfn_type_express" {

  command = plan

  variables {
    type = "EXPRESS"
  }

  assert {
    condition     = aws_sfn_state_machine.main.type == "EXPRESS"
    error_message = "Expected Step Function type to be EXPRESS when type variable is set to EXPRESS"
  }
}

run "sfn_publish_enabled" {

  command = plan

  variables {
    publish = true
  }

  assert {
    condition     = aws_sfn_state_machine.main.publish == true
    error_message = "Expected publish to be true when publish variable is set to true"
  }
}

run "sfn_xray_tracing_enabled" {

  command = plan

  variables {
    enable_xray_tracing = true
  }

  assert {
    condition     = length(aws_sfn_state_machine.main.tracing_configuration) > 0
    error_message = "Expected tracing_configuration to be set when enable_xray_tracing is set to true"
  }
}