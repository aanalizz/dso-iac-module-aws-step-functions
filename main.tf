locals {

  resource_name = "${var.cloud_provider}-${var.environment}-sfn-${var.app_name}-${var.resource_suffix}-${var.correlative}"

  enable_logging = lookup(var.logging_configuration, "level", "OFF") != "OFF"

  # Normalize ARN by trimming ":*" because data-source has it, but resource does not have it
  log_group_arn = local.enable_logging ? trimsuffix(var.use_existing_cloudwatch_log_group ? data.aws_cloudwatch_log_group.sfn.arn : aws_cloudwatch_log_group.sfn.arn, ":*") : ""

}

resource "aws_sfn_state_machine" "main" {
  lifecycle {
    enabled = var.create
    ignore_changes = [
      definition
    ]
  }

  name = local.resource_name

  role_arn   = var.role_arn
  definition = <<EOF
{
  "Comment": "Dummy state machine definition",
  "StartAt": "PassState",
  "States": {
    "PassState": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF
  publish    = var.publish

  dynamic "encryption_configuration" {
    for_each = length(var.encryption_configuration) > 0 ? [var.encryption_configuration] : []

    content {
      type                              = encryption_configuration.value.type
      kms_key_id                        = lookup(encryption_configuration.value, "kms_key_id", null)
      kms_data_key_reuse_period_seconds = lookup(encryption_configuration.value, "kms_data_key_reuse_period_seconds", null)
    }
  }

  dynamic "logging_configuration" {
    for_each = local.enable_logging ? [true] : []

    content {
      log_destination        = lookup(var.logging_configuration, "log_destination", "${local.log_group_arn}:*")
      include_execution_data = lookup(var.logging_configuration, "include_execution_data", null)
      level                  = lookup(var.logging_configuration, "level", null)
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.enable_xray_tracing ? [true] : []
    content {
      enabled = true
    }
  }

  type = upper(var.type)

  timeouts {
    create = lookup(var.sfn_state_machine_timeouts, "create", null)
    delete = lookup(var.sfn_state_machine_timeouts, "delete", null)
    update = lookup(var.sfn_state_machine_timeouts, "update", null)
  }

  tags = merge(
    {
      Name = local.resource_name
    }
  )

  depends_on = [
    # Depending on the log group is necessary to allow Terraform to create the log group before AWS can.
    # When a Step Function execution starts, AWS may create the log group automatically if it doesn't exist yet.
    # Without the dependency, this can result in a race condition if the state machine is started before
    # Terraform can create the log group.
    aws_cloudwatch_log_group.sfn
  ]
}

##################
# CloudWatch Logs
##################

data "aws_cloudwatch_log_group" "sfn" {
  lifecycle {
    enabled = var.create && local.enable_logging && var.use_existing_cloudwatch_log_group
  }

  name = coalesce(var.cloudwatch_log_group_name, "/aws/states/${local.resource_name}")
}


resource "aws_cloudwatch_log_group" "sfn" {

  lifecycle {
    enabled = var.create && local.enable_logging && !var.use_existing_cloudwatch_log_group
  }

  name              = coalesce(var.cloudwatch_log_group_name, "/aws/states/${local.resource_name}")
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  skip_destroy      = var.cloudwatch_logs_skip_destroy
}