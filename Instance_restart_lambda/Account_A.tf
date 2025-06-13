provider "aws" {
  region = "ap-south-1"  # Change to your region
}

# Data source for existing Lambda function
data "aws_lambda_function" "ec2_reboot_lambda" {
  function_name = "ec2_reboot_function"  # Replace with your actual Lambda function name
}

# Data source for existing target group
data "aws_lb_target_group" "target_group" {
  name = "your-target-group-name"  # Replace with your actual target group name
}

# Data source for existing load balancer
data "aws_lb" "load_balancer" {
  name = "your-load-balancer-name"  # Replace with your actual load balancer name
}

# CloudWatch alarm for unhealthy hosts with direct Lambda action
resource "aws_cloudwatch_metric_alarm" "target_group_unhealthy_hosts" {
  alarm_name          = "target-group-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This alarm triggers when there are unhealthy hosts in the target group"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    TargetGroup  = data.aws_lb_target_group.target_group.arn_suffix
    LoadBalancer = data.aws_lb.load_balancer.arn_suffix
  }
  
  alarm_actions = [data.aws_lambda_function.ec2_reboot_lambda.arn]
}

# Permission for CloudWatch to invoke Lambda
resource "aws_lambda_permission" "cloudwatch_lambda_permission" {
  statement_id  = "AllowCloudWatchToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.ec2_reboot_lambda.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.target_group_unhealthy_hosts.arn
}

# Output the CloudWatch alarm ARN
output "cloudwatch_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.target_group_unhealthy_hosts.arn
}