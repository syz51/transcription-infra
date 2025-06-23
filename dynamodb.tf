# DynamoDB Table for tracking audio extraction states
resource "aws_dynamodb_table" "extraction_state" {
  name           = "${local.project_name}-extraction-state-${var.environment}"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "job_id"
  range_key      = "timestamp"

  attribute {
    name = "job_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "video_key"
    type = "S"
  }

  # Global Secondary Index for querying by status
  global_secondary_index {
    name            = "status-index"
    hash_key        = "status"
    range_key       = "timestamp"
    write_capacity  = var.dynamodb_write_capacity
    read_capacity   = var.dynamodb_read_capacity
    projection_type = "ALL"
  }

  # Global Secondary Index for querying by video key
  global_secondary_index {
    name            = "video-key-index"
    hash_key        = "video_key"
    range_key       = "timestamp"
    write_capacity  = var.dynamodb_write_capacity
    read_capacity   = var.dynamodb_read_capacity
    projection_type = "ALL"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  # TTL configuration (optional - items expire after 30 days)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.common_tags, {
    Name = "Audio Extraction State Table"
    Type = "dynamodb-table"
  })
}
