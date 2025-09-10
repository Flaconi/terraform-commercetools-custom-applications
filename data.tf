data "aws_iam_policy_document" "this" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.s3.s3_bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      values   = ["arn:aws:cloudfront::${var.aws_account_id}:distribution/${module.cdn.cloudfront_distribution_id}"]
      variable = "AWS:SourceArn"
    }
  }
}
