resource "aws_sns_topic" "transcoded_video_topic" {
  name = "transcoded_video_topic"

  provisioner "local-exec" {
    command = "sh sns_subscription.sh"
    environment = {
      sns_arn    = self.arn
      sns_emails = var.sns_emails
    }
  }

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:transcoded_video_topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn": "${aws_s3_bucket.bucket.1.arn}"}}
    }]
}
POLICY
}

resource "aws_sns_topic_subscription" "transcoded_video_lambda_subscription" {
  topic_arn = aws_sns_topic.transcoded_video_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.set_permissions.arn
}
