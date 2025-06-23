# Development Environment Configuration
aws_region  = "eu-west-2"
environment = "dev"

# Project Configuration
project_name = "audio-extraction"

# S3 Bucket Names (will have environment and random suffix appended)
video_input_bucket_name  = "audio-extraction-videos"
audio_output_bucket_name = "audio-extraction-audio-output"

# Lambda Configuration
lambda_timeout     = 300 # 5 minutes
lambda_memory_size = 512 # MB

# SQS Configuration
enable_s3_notifications = true
sqs_visibility_timeout  = 320 # seconds (slightly higher than lambda timeout)

# DynamoDB Configuration (lower capacity for dev)
dynamodb_read_capacity  = 1
dynamodb_write_capacity = 1

# CloudWatch settings
cloudwatch_log_retention_days = 7
lambda_error_threshold        = 10
enable_sns_notifications      = false
alert_email                   = ""
