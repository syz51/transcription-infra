# S3 Bucket for Video Input
resource "aws_s3_bucket" "video_input" {
  bucket = "${var.video_input_bucket_name}-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "Video Input Bucket"
    Type = "video-input"
  })
}

resource "aws_s3_bucket_versioning" "video_input" {
  bucket = aws_s3_bucket.video_input.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "video_input" {
  bucket = aws_s3_bucket.video_input.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "video_input" {
  bucket = aws_s3_bucket.video_input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Audio Output
resource "aws_s3_bucket" "audio_output" {
  bucket = "${var.audio_output_bucket_name}-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "Audio Output Bucket"
    Type = "audio-output"
  })
}

resource "aws_s3_bucket_versioning" "audio_output" {
  bucket = aws_s3_bucket.audio_output.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audio_output" {
  bucket = aws_s3_bucket.audio_output.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "audio_output" {
  bucket = aws_s3_bucket.audio_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Notification for Video Input
resource "aws_s3_bucket_notification" "video_input_notification" {
  count  = var.enable_s3_notifications ? 1 : 0
  bucket = aws_s3_bucket.video_input.id

  queue {
    queue_arn = aws_sqs_queue.video_processing.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_suffix = ".mp4"
  }

  queue {
    queue_arn = aws_sqs_queue.video_processing.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_suffix = ".mov"
  }

  queue {
    queue_arn = aws_sqs_queue.video_processing.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_suffix = ".avi"
  }

  queue {
    queue_arn = aws_sqs_queue.video_processing.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_suffix = ".mkv"
  }

  depends_on = [aws_sqs_queue_policy.video_processing_policy]
}

# Random ID for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for FFmpeg Binaries (Lambda Layer)
resource "aws_s3_bucket" "ffmpeg_binaries" {
  bucket = "${var.ffmpeg_binaries_bucket_name}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "FFmpeg Binaries Bucket"
    Type = "lambda-layer-storage"
  })
}

resource "aws_s3_bucket_versioning" "ffmpeg_binaries" {
  bucket = aws_s3_bucket.ffmpeg_binaries.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ffmpeg_binaries" {
  bucket = aws_s3_bucket.ffmpeg_binaries.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ffmpeg_binaries" {
  bucket = aws_s3_bucket.ffmpeg_binaries.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload FFmpeg layer ZIP to S3
resource "aws_s3_object" "ffmpeg_layer_zip" {
  bucket      = aws_s3_bucket.ffmpeg_binaries.id
  key         = "layers/ffmpeg-layer.zip"
  source      = archive_file.ffmpeg_layer_zip.output_path
  source_hash = archive_file.ffmpeg_layer_zip.output_base64sha256

  tags = merge(local.common_tags, {
    Name = "FFmpeg Layer Archive"
    Type = "lambda-layer"
  })
}
