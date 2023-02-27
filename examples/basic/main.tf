module "example" {
  source = "../../"

  alarm_description   = "Alarm when path success rate drops below threshold"
  path                = "/api/v1/users"
  datapoints_to_alarm = 2
  evaluation_periods  = 2
  threshold           = 95
  period              = 300

  alarm_topic_arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
}
