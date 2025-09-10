moved {
  from = data.aws_iam_policy_document.cloudfront
  to   = data.aws_iam_policy_document.this
}

moved {
  from = aws_s3_bucket_policy.cloudfront
  to   = module.s3.aws_s3_bucket_policy.this[0]
}
