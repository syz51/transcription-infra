variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "audio-extraction"
}

variable "video_input_bucket_name" {
  description = "Name of the S3 bucket for input video files"
  type        = string
  default     = "audio-extraction-videos"
}

variable "audio_output_bucket_name" {
  description = "Name of the S3 bucket for output audio files"
  type        = string
  default     = "audio-extraction-audio-output"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "enable_s3_notifications" {
  description = "Enable S3 bucket notifications to SQS"
  type        = bool
  default     = true
}

variable "sqs_visibility_timeout" {
  description = "SQS queue visibility timeout in seconds"
  type        = number
  default     = 320
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units"
  type        = number
  default     = 5
}

# CloudWatch variables
variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
}

variable "lambda_error_threshold" {
  description = "Threshold for Lambda error rate alarm"
  type        = number
  default     = 5
}

variable "lambda_duration_threshold" {
  description = "Threshold for Lambda duration alarm (in milliseconds)"
  type        = number
  default     = 240000 # 4 minutes (80% of 5-minute timeout)
}

variable "sqs_queue_depth_threshold" {
  description = "Threshold for SQS queue depth alarm"
  type        = number
  default     = 10
}

variable "s3_error_threshold" {
  description = "Threshold for S3 4xx error alarm"
  type        = number
  default     = 5
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for CloudWatch alarms"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "ffmpeg_binaries_bucket_name" {
  description = "Name of the S3 bucket for FFmpeg binaries (Lambda layer storage)"
  type        = string
  default     = "ffmpeg-binaries"
}

variable "ffmpeg_layer_description" {
  description = "Description for the FFmpeg Lambda layer"
  type        = string
  default     = "FFmpeg and FFprobe binaries for video processing"
}
