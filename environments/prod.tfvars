# Production Environment Configuration
aws_region  = "eu-west-2"
environment = "prod"

# Project Configuration
project_name = "audio-extraction"

# S3 Bucket Names (will have environment and random suffix appended)
video_input_bucket_name  = "audio-extraction-videos"
audio_output_bucket_name = "audio-extraction-audio-output"

# Lambda Configuration
lambda_timeout     = 900  # 15 minutes for production
lambda_memory_size = 1024 # 1GB for better performance

# SQS Configuration
enable_s3_notifications = true
sqs_visibility_timeout  = 920 # seconds (slightly higher than lambda timeout)

# DynamoDB Configuration (higher capacity for prod)
dynamodb_read_capacity  = 10
dynamodb_write_capacity = 10

# CloudWatch settings
cloudwatch_log_retention_days = 30
lambda_error_threshold        = 3
enable_sns_notifications      = true
alert_email                   = "syzroy@gmail.com"
