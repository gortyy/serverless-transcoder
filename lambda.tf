# TODO create module out of it
resource "aws_lambda_function" "transcode" {
  function_name = var.transcode_video_lambda_name
  s3_bucket     = aws_s3_bucket_object.transcode_lambda_zip.bucket
  s3_key        = aws_s3_bucket_object.transcode_lambda_zip.key
  handler       = var.transcode_video_lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda.arn
}

resource "aws_lambda_function" "set_permissions" {
  function_name = var.set_permissions_lambda_name
  s3_bucket     = aws_s3_bucket_object.set_permissions_lambda_zip.bucket
  s3_key        = aws_s3_bucket_object.set_permissions_lambda_zip.key
  handler       = var.set_permissions_lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.set_permissions_lambda.arn
}

resource "aws_s3_bucket_object" "transcode_lambda_zip" {
  bucket = var.buckets_mapper.lambda_functions
  key    = join("/", [var.transcode_video_lambda_name, "1.0.0", basename("./${var.transcode_video_lambda_name}.zip")])
  source = "./${var.transcode_video_lambda_name}.zip"
}

resource "aws_s3_bucket_object" "set_permissions_lambda_zip" {
  bucket = var.buckets_mapper.lambda_functions
  key    = join("/", [var.set_permissions_lambda_name, "1.0.0", basename("./${var.set_permissions_lambda_name}.zip")])
  source = "./${var.set_permissions_lambda_name}.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transcode.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.0.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.set_permissions.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.transcoded_video_topic.arn
}
