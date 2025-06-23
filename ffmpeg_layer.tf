# Lambda Layer for FFmpeg/FFprobe binaries
resource "aws_lambda_layer_version" "ffmpeg_layer" {
  s3_bucket                = aws_s3_bucket.ffmpeg_binaries.id
  s3_key                   = aws_s3_object.ffmpeg_layer_zip.key
  layer_name               = "${local.project_name}-ffmpeg-layer"
  description              = var.ffmpeg_layer_description
  compatible_architectures = ["x86_64"]
  source_code_hash         = aws_s3_object.ffmpeg_layer_zip.source_hash

  depends_on = [aws_s3_object.ffmpeg_layer_zip]
}
