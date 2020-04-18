resource "aws_s3_bucket" "bucket" {
  count         = length(var.buckets)
  bucket        = var.buckets[count.index]
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_notification" "upload_notification" {
  bucket = aws_s3_bucket.bucket.0.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcode.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcode.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".avi"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcode.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mov"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_notification" "transcoded_video_notification" {
  bucket = aws_s3_bucket.bucket.1.id

  topic {
    topic_arn     = aws_sns_topic.transcoded_video_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".mp4"
  }
}
