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

run "no_encryption_by_default" {

  command = plan

  assert {
    condition     = length(aws_sfn_state_machine.main.encryption_configuration) == 0
    error_message = "Expected no encryption_configuration to be planned when encryption_configuration variable is empty by default"
  }
}

run "creates_sfn_with_customer_managed_kms_encryption" {

  command = plan

  variables {
    encryption_configuration = {
      type                              = "CUSTOMER_MANAGED_KMS_KEY"
      kms_key_id                        = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      kms_data_key_reuse_period_seconds = 300
    }
  }

  assert {
    condition     = length(aws_sfn_state_machine.main.encryption_configuration) > 0
    error_message = "Expected encryption_configuration to be planned when encryption_configuration variable is provided"
  }

  assert {
    condition     = aws_sfn_state_machine.main.encryption_configuration[0].type == "CUSTOMER_MANAGED_KMS_KEY"
    error_message = "Expected encryption type to be CUSTOMER_MANAGED_KMS_KEY when encryption_configuration type is set to CUSTOMER_MANAGED_KMS_KEY"
  }
}