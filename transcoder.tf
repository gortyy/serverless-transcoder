

resource "aws_elastictranscoder_pipeline" "transcoder" {
  input_bucket = var.buckets_mapper.input
  name         = "transcoder_pipeline"
  role         = aws_iam_role.transcoder.arn

  content_config {
    bucket        = var.buckets_mapper.content_bucket
    storage_class = "Standard"
  }

  thumbnail_config {
    bucket        = var.buckets_mapper.thumb_bucket
    storage_class = "Standard"
  }
}
