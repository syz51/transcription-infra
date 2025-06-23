# SQS Queue for video processing notifications
resource "aws_sqs_queue" "video_processing" {
  name                       = "${local.project_name}-video-processing-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 1209600 # 14 days
  receive_wait_time_seconds  = 10      # Enable long polling
  visibility_timeout_seconds = var.sqs_visibility_timeout

  # Dead letter queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(local.common_tags, {
    Name = "Video Processing Queue"
    Type = "sqs-queue"
  })
}

# Dead Letter Queue for failed video processing messages
resource "aws_sqs_queue" "video_processing_dlq" {
  name                      = "${local.project_name}-video-processing-dlq-${var.environment}"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(local.common_tags, {
    Name = "Video Processing Dead Letter Queue"
    Type = "sqs-dlq"
  })
}

# SQS Queue Policy to allow S3 to send messages
resource "aws_sqs_queue_policy" "video_processing_policy" {
  queue_url = aws_sqs_queue.video_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowS3Notification"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.video_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.video_input.arn
          }
        }
      }
    ]
  })
}

# Dead Letter Queue redrive allow policy
resource "aws_sqs_queue_redrive_allow_policy" "video_processing_dlq_redrive" {
  queue_url = aws_sqs_queue.video_processing_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.video_processing.arn]
  })
}
