resource "aws_iam_role" "transcoder" {
  name = var.transcoder_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "elastictranscoder.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda" {
  name               = var.transcode_video_lambda_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "set_permissions_lambda" {
  name               = var.set_permisions_lambda_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "transcoder" {
  name        = var.transcoder_policy_name
  description = "Basic transcoder policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
         "Sid":"1",
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:Put*",
            "s3:Get*",
            "s3:*MultipartUpload*"
         ],
         "Resource":"*"
      },
      {
         "Sid":"2",
         "Effect":"Allow",
         "Action":"sns:Publish",
         "Resource":"*"
      },
      {
         "Sid":"3",
         "Effect":"Deny",
         "Action":[
            "s3:*Policy*",
            "sns:*Permission*",
            "s3:*Acl*",
            "sns:*Delete*",
            "s3:*Delete*",
            "sns:*Remove*"
         ],
         "Resource":"*"
      }
   ]
}
EOF
}

resource "aws_iam_policy" "lambda_s3" {
  name        = var.cloudwatch_and_s3_lambda_policy_name
  description = "Interact with S3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "${aws_s3_bucket.bucket.1.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_transcoder" {
  name        = var.transcoder_lambda_policy_name
  description = "trigger transcoder jobs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elastictranscoder:Read*",
                "elastictranscoder:List*",
                "elastictranscoder:*Job",
                "elastictranscoder:*Preset",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "iam:ListRoles",
                "sns:ListTopics"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "transcoder" {
  role       = aws_iam_role.transcoder.name
  policy_arn = aws_iam_policy.transcoder.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_role_policy_attachment" "lambda_transcoder" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_transcoder.arn
}

resource "aws_iam_role_policy_attachment" "set_permissions_s3" {
  role       = aws_iam_role.set_permissions_lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}
