provider "aws" {
  region = "us-east-1"
}

mock_provider "aws" {
  mock_data "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/states/aws-dev-sfn-myapp-sfn-01:*"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/states/aws-dev-sfn-myapp-sfn-01:*"
    }
  }
}

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

run "creates_cloudwatch_log_group_when_logging_enabled" {

  command = plan

  variables {
    logging_configuration = {
      level                  = "ALL"
      include_execution_data = true
    }
    use_existing_cloudwatch_log_group = false
  }

  assert {
    condition     = aws_cloudwatch_log_group.sfn.name == "/aws/states/aws-dev-sfn-cph-sfn-01"
    error_message = "Expected aws_cloudwatch_log_group name to be set when logging is enabled and use_existing_cloudwatch_log_group is false"
  }

  assert {
    condition     = aws_sfn_state_machine.main.logging_configuration[0].level == "ALL"
    error_message = "Expected logging level to be ALL when logging_configuration level is set to ALL"
  }
}

run "uses_existing_cloudwatch_log_group" {

  command = plan

  variables {
    logging_configuration = {
      level                  = "ERROR"
      include_execution_data = false
    }
    use_existing_cloudwatch_log_group = true
  }

  assert {
    condition     = data.aws_cloudwatch_log_group.sfn.name == "/aws/states/aws-dev-sfn-cph-sfn-01"
    error_message = "Expected data.aws_cloudwatch_log_group name to be set when use_existing_cloudwatch_log_group is set to true"
  }
}

run "log_group_retention_configuration" {

  command = plan

  variables {
    logging_configuration = {
      level = "ALL"
    }
    use_existing_cloudwatch_log_group          = false
    cloudwatch_log_group_retention_in_days     = 30
  }

  assert {
    condition     = aws_cloudwatch_log_group.sfn.retention_in_days == 30
    error_message = "Expected log group retention_in_days to be 30 when cloudwatch_log_group_retention_in_days is set to 30"
  }
}