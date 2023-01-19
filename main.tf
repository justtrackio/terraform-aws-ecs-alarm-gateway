module "cloudwatch_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  delimiter   = "/"
  label_order = var.label_orders.cloudwatch

  context = module.this.context
}

resource "aws_cloudwatch_metric_alarm" "path_success_rate" {
  count = module.this.enabled ? 1 : 0

  alarm_description   = var.alarm_description
  alarm_name          = "${module.this.id}-${var.path}-success-rate"
  datapoints_to_alarm = var.datapoints_to_alarm
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_periods
  threshold           = var.success_rate_threshold
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "requests"
    return_data = false

    metric {
      metric_name = "ApiRequestCount"
      namespace   = module.cloudwatch_label.id
      dimensions = {
        "path" = var.path
      }
      period = var.period
      stat   = "Sum"
    }
  }

  metric_query {
    id          = "errors"
    return_data = false

    metric {
      metric_name = "ApiStatus5XX"
      namespace   = module.cloudwatch_label.id
      dimensions = {
        "path" = var.path
      }
      period = var.period
      stat   = "Sum"
    }
  }

  metric_query {
    expression  = "IF(requests == 0 OR errors == 0, 100, 100-100*(errors/requests))"
    id          = "e1"
    label       = "100-100*(errors/requests)"
    return_data = true
  }

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]

  tags = module.this.tags
}
