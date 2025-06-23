# Package Lambda function code
# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda"
#   output_path = "${path.module}/lambda-deployment-package.zip"
#   excludes    = ["__pycache__", "*.pyc", ".DS_Store"]
# }

# Package FFmpeg layer
resource "archive_file" "ffmpeg_layer_zip" {
  type             = "zip"
  source_dir       = "${path.module}/lambda-layers/ffmpeg"
  output_path      = "${path.module}/ffmpeg-layer.zip"
  output_file_mode = "0666"
  excludes         = [".DS_Store"]
}

# Current AWS caller identity
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}

# Available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
