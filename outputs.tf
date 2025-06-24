output "video_input_bucket_name" {
  description = "Name of the video input S3 bucket"
  value       = aws_s3_bucket.video_input.bucket
}

output "audio_output_bucket_name" {
  description = "Name of the audio output S3 bucket"
  value       = aws_s3_bucket.audio_output.bucket
}

output "ffmpeg_binaries_bucket_name" {
  description = "Name of the FFmpeg binaries S3 bucket"
  value       = aws_s3_bucket.ffmpeg_binaries.bucket
}

output "ffmpeg_layer_arn" {
  description = "ARN of the FFmpeg Lambda layer"
  value       = aws_lambda_layer_version.ffmpeg_layer.arn
}

output "ffmpeg_layer_version" {
  description = "Version of the FFmpeg Lambda layer"
  value       = aws_lambda_layer_version.ffmpeg_layer.version
}

output "video_processing_queue_url" {
  description = "URL of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.url
}

output "video_processing_queue_arn" {
  description = "ARN of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for tracking extraction states"
  value       = aws_dynamodb_table.extraction_state.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for tracking extraction states"
  value       = aws_dynamodb_table.extraction_state.arn
}

# output "lambda_function_name" {
#   description = "Name of the Lambda function for metadata extraction"
#   value       = aws_lambda_function.metadata_extractor_with_layer.function_name
# }

# output "lambda_function_arn" {
#   description = "ARN of the Lambda function for metadata extraction"
#   value       = aws_lambda_function.metadata_extractor_with_layer.arn
# }

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

# CloudWatch Outputs
output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.audio_extraction_dashboard.dashboard_name}"
}

# output "lambda_log_group_name" {
#   description = "Name of the Lambda CloudWatch log group"
#   value       = aws_cloudwatch_log_group.metadata_extractor.name
# }

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS topic for alerts (if enabled)"
  value       = var.enable_sns_notifications ? aws_sns_topic.alerts[0].arn : null
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm names and ARNs"
  value = {
    # lambda_errors      = aws_cloudwatch_metric_alarm.lambda_error_rate.arn
    # lambda_duration    = aws_cloudwatch_metric_alarm.lambda_duration.arn
    sqs_queue_depth    = aws_cloudwatch_metric_alarm.sqs_queue_depth.arn
    dlq_messages       = aws_cloudwatch_metric_alarm.dlq_messages.arn
    dynamodb_throttles = aws_cloudwatch_metric_alarm.dynamodb_throttles.arn
    s3_4xx_errors      = aws_cloudwatch_metric_alarm.s3_4xx_errors.arn
  }
}
