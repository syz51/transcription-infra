# # ========================================
# # CloudWatch Log Groups for Comprehensive Logging
# # ========================================

# # Additional log groups for S3 access logging (if needed via CloudTrail)
# resource "aws_cloudwatch_log_group" "s3_access_logs" {
#   name              = "/aws/s3/${local.project_name}-access-logs-${var.environment}"
#   retention_in_days = var.cloudwatch_log_retention_days

#   tags = merge(local.common_tags, {
#     Name = "S3 Access Logs"
#     Type = "log-group"
#   })
# }

# # SQS CloudWatch log group for monitoring
# resource "aws_cloudwatch_log_group" "sqs_monitoring" {
#   name              = "/aws/sqs/${local.project_name}-monitoring-${var.environment}"
#   retention_in_days = var.cloudwatch_log_retention_days

#   tags = merge(local.common_tags, {
#     Name = "SQS Monitoring Logs"
#     Type = "log-group"
#   })
# }

# # DynamoDB CloudWatch log group
# resource "aws_cloudwatch_log_group" "dynamodb_logs" {
#   name              = "/aws/dynamodb/${local.project_name}-${var.environment}"
#   retention_in_days = var.cloudwatch_log_retention_days

#   tags = merge(local.common_tags, {
#     Name = "DynamoDB Logs"
#     Type = "log-group"
#   })
# }

# # Application-level log group for custom metrics and events
# resource "aws_cloudwatch_log_group" "application_logs" {
#   name              = "/aws/application/${local.project_name}-${var.environment}"
#   retention_in_days = var.cloudwatch_log_retention_days

#   tags = merge(local.common_tags, {
#     Name = "Application Logs"
#     Type = "log-group"
#   })
# }

# # ========================================
# # CloudWatch Log Metric Filters
# # ========================================

# # Lambda Error Tracking
# resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
#   name           = "${local.project_name}-lambda-errors-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

#   metric_transformation {
#     name      = "LambdaErrors"
#     namespace = "AudioExtraction/Lambda"
#     value     = "1"

#     dimensions = {
#       Environment = var.environment
#       Function    = aws_lambda_function.metadata_extractor_with_layer.function_name
#     }
#   }
# }

# # Lambda Duration Tracking
# resource "aws_cloudwatch_log_metric_filter" "lambda_duration" {
#   name           = "${local.project_name}-lambda-duration-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, \"REPORT\", request_id_2, \"Duration:\", duration, \"ms\", ...]"

#   metric_transformation {
#     name      = "LambdaDuration"
#     namespace = "AudioExtraction/Lambda"
#     value     = "$duration"
#     unit      = "Milliseconds"

#     dimensions = {
#       Environment = var.environment
#       Function    = aws_lambda_function.metadata_extractor_with_layer.function_name
#     }
#   }
# }

# # Lambda Memory Usage Tracking
# resource "aws_cloudwatch_log_metric_filter" "lambda_memory" {
#   name           = "${local.project_name}-lambda-memory-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, \"REPORT\", request_id_2, \"Duration:\", duration, \"ms\", \"Billed Duration:\", billed_duration, \"ms\", \"Memory Size:\", memory_size, \"MB\", \"Max Memory Used:\", max_memory_used, \"MB\", ...]"

#   metric_transformation {
#     name      = "LambdaMaxMemoryUsed"
#     namespace = "AudioExtraction/Lambda"
#     value     = "$max_memory_used"
#     unit      = "Megabytes"

#     dimensions = {
#       Environment = var.environment
#       Function    = aws_lambda_function.metadata_extractor_with_layer.function_name
#     }
#   }
# }

# # Processing Success Rate
# resource "aws_cloudwatch_log_metric_filter" "processing_success" {
#   name           = "${local.project_name}-processing-success-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, level=\"INFO\", message=\"Updated job record*with metadata\"]"

#   metric_transformation {
#     name      = "ProcessingSuccess"
#     namespace = "AudioExtraction/Processing"
#     value     = "1"

#     dimensions = {
#       Environment = var.environment
#       Status      = "success"
#     }
#   }
# }

# # Processing Failures
# resource "aws_cloudwatch_log_metric_filter" "processing_failures" {
#   name           = "${local.project_name}-processing-failures-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, level=\"ERROR\", message=\"Error processing*\"]"

#   metric_transformation {
#     name      = "ProcessingFailures"
#     namespace = "AudioExtraction/Processing"
#     value     = "1"

#     dimensions = {
#       Environment = var.environment
#       Status      = "failure"
#     }
#   }
# }

# # Video File Size Tracking
# resource "aws_cloudwatch_log_metric_filter" "video_file_size" {
#   name           = "${local.project_name}-video-file-size-${var.environment}"
#   log_group_name = aws_cloudwatch_log_group.metadata_extractor.name
#   pattern        = "[timestamp, request_id, level=\"INFO\", message=\"Processing S3 object:*\", object_info]"

#   metric_transformation {
#     name      = "VideoFileProcessed"
#     namespace = "AudioExtraction/Files"
#     value     = "1"

#     dimensions = {
#       Environment = var.environment
#       Type        = "video"
#     }
#   }
# }

# # ========================================
# # CloudWatch Metric Alarms
# # ========================================

# # Lambda Error Rate Alarm
# resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
#   alarm_name          = "${local.project_name}-lambda-error-rate-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = var.lambda_error_threshold
#   alarm_description   = "This metric monitors lambda error rate"

#   dimensions = {
#     FunctionName = aws_lambda_function.metadata_extractor_with_layer.function_name
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "Lambda Error Rate Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # Lambda Duration Alarm
# resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
#   alarm_name          = "${local.project_name}-lambda-duration-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "Duration"
#   namespace           = "AWS/Lambda"
#   period              = 300
#   statistic           = "Average"
#   threshold           = var.lambda_duration_threshold
#   alarm_description   = "This metric monitors lambda execution duration"

#   dimensions = {
#     FunctionName = aws_lambda_function.metadata_extractor_with_layer.function_name
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "Lambda Duration Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # SQS Queue Depth Alarm
# resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
#   alarm_name          = "${local.project_name}-sqs-queue-depth-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "ApproximateNumberOfVisibleMessages"
#   namespace           = "AWS/SQS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = var.sqs_queue_depth_threshold
#   alarm_description   = "This metric monitors SQS queue depth"

#   dimensions = {
#     QueueName = aws_sqs_queue.video_processing.name
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "SQS Queue Depth Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # DLQ Messages Alarm
# resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
#   alarm_name          = "${local.project_name}-dlq-messages-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "ApproximateNumberOfVisibleMessages"
#   namespace           = "AWS/SQS"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = 0
#   alarm_description   = "This metric monitors dead letter queue for failed messages"

#   dimensions = {
#     QueueName = aws_sqs_queue.video_processing_dlq.name
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "DLQ Messages Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # DynamoDB Throttling Alarm
# resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
#   alarm_name          = "${local.project_name}-dynamodb-throttles-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "UserErrors"
#   namespace           = "AWS/DynamoDB"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = 0
#   alarm_description   = "This metric monitors DynamoDB throttling events"

#   dimensions = {
#     TableName = aws_dynamodb_table.extraction_state.name
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "DynamoDB Throttles Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # S3 4XX Error Alarm
# resource "aws_cloudwatch_metric_alarm" "s3_4xx_errors" {
#   alarm_name          = "${local.project_name}-s3-4xx-errors-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "4xxErrors"
#   namespace           = "AWS/S3"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = var.s3_error_threshold
#   alarm_description   = "This metric monitors S3 4xx errors"

#   dimensions = {
#     BucketName = aws_s3_bucket.video_input.bucket
#   }

#   alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []

#   tags = merge(local.common_tags, {
#     Name = "S3 4XX Errors Alarm"
#     Type = "cloudwatch-alarm"
#   })
# }

# # ========================================
# # SNS Topic for Alerts (Optional)
# # ========================================

# resource "aws_sns_topic" "alerts" {
#   count = var.enable_sns_notifications ? 1 : 0
#   name  = "${local.project_name}-alerts-${var.environment}"

#   tags = merge(local.common_tags, {
#     Name = "Alert Notifications"
#     Type = "sns-topic"
#   })
# }

# resource "aws_sns_topic_subscription" "email_alerts" {
#   count     = var.enable_sns_notifications && var.alert_email != "" ? 1 : 0
#   topic_arn = aws_sns_topic.alerts[0].arn
#   protocol  = "email"
#   endpoint  = var.alert_email
# }

# # ========================================
# # CloudWatch Dashboard
# # ========================================

# resource "aws_cloudwatch_dashboard" "audio_extraction_dashboard" {
#   dashboard_name = "${local.project_name}-dashboard-${var.environment}"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 12
#         height = 6

#         properties = {
#           metrics = [
#             ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.metadata_extractor_with_layer.function_name],
#             [".", "Errors", ".", "."],
#             [".", "Invocations", ".", "."]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = var.aws_region
#           title   = "Lambda Function Metrics"
#           period  = 300
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 0
#         width  = 12
#         height = 6

#         properties = {
#           metrics = [
#             ["AWS/SQS", "ApproximateNumberOfVisibleMessages", "QueueName", aws_sqs_queue.video_processing.name],
#             [".", "ApproximateNumberOfVisibleMessages", "QueueName", aws_sqs_queue.video_processing_dlq.name]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = var.aws_region
#           title   = "SQS Queue Metrics"
#           period  = 300
#         }
#       },
#       {
#         type   = "metric"
#         x      = 0
#         y      = 6
#         width  = 12
#         height = 6

#         properties = {
#           metrics = [
#             ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.extraction_state.name],
#             [".", "ConsumedWriteCapacityUnits", ".", "."]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = var.aws_region
#           title   = "DynamoDB Capacity Metrics"
#           period  = 300
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 6
#         width  = 12
#         height = 6

#         properties = {
#           metrics = [
#             ["AWS/S3", "BucketSizeBytes", "BucketName", aws_s3_bucket.video_input.bucket, "StorageType", "StandardStorage"],
#             [".", "NumberOfObjects", ".", ".", ".", "AllStorageTypes"],
#             [".", "BucketSizeBytes", "BucketName", aws_s3_bucket.audio_output.bucket, "StorageType", "StandardStorage"]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = var.aws_region
#           title   = "S3 Storage Metrics"
#           period  = 86400
#         }
#       },
#       {
#         type   = "log"
#         x      = 0
#         y      = 12
#         width  = 24
#         height = 6

#         properties = {
#           query = join("", [
#             "SOURCE '${aws_cloudwatch_log_group.metadata_extractor.name}'\n",
#             "| fields @timestamp, @message\n",
#             "| filter @message like /ERROR/\n",
#             "| sort @timestamp desc\n",
#             "| limit 100"
#           ])
#           region = var.aws_region
#           title  = "Recent Lambda Errors"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 0
#         y      = 18
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["AudioExtraction/Processing", "ProcessingSuccess", "Environment", var.environment],
#             [".", "ProcessingFailures", ".", "."]
#           ]
#           view   = "singleValue"
#           region = var.aws_region
#           title  = "Processing Success Rate"
#           period = 300
#           stat   = "Sum"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 8
#         y      = 18
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["AudioExtraction/Lambda", "LambdaErrors", "Environment", var.environment]
#           ]
#           view   = "singleValue"
#           region = var.aws_region
#           title  = "Lambda Error Count"
#           period = 300
#           stat   = "Sum"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 16
#         y      = 18
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["AudioExtraction/Files", "VideoFileProcessed", "Environment", var.environment]
#           ]
#           view   = "singleValue"
#           region = var.aws_region
#           title  = "Videos Processed"
#           period = 300
#           stat   = "Sum"
#         }
#       }
#     ]
#   })

# }
