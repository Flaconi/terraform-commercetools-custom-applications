resource "aws_cloudfront_function" "rewrite_sub_folder_index" {
  name    = "${var.app_name}-rewrite-sub-folder-index"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrites each request to the subfolder index.html"
  publish = true
  code = templatefile("rewrite_subfolder.js.tftpl",
    {
      applications = jsonencode(keys(var.applications))
    }
  )
}

module "ssm" {
  source = "github.com/Flaconi/terraform-aws-ssm-store?ref=v1.1.0"

  for_each = var.applications

  tags = merge(each.value.tags, { Project = each.key })

  kms_alias = "alias/aws/ssm"

  name_prefix = "${var.ssm_name_prefix}/${each.key}/"
  parameters = concat([
    {
      name  = "cloudfront_domain_name"
      value = module.cdn.cloudfront_distribution_domain_name
    },
    {
      name  = "bucket_name"
      value = module.s3.s3_bucket_id
    },
    {
      name  = "application_id"
      value = each.value.application_id
    },
  ], each.value.additional_ssm_parameters)

}

module "cdn" {

  create_distribution = length(var.applications) > 0
  source              = "github.com/terraform-aws-modules/terraform-aws-cloudfront?ref=v3.2.1"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  tags = var.tags

  create_origin_access_control = true
  origin_access_control = {
    "${var.app_name}-origin-access-control" = {
      description      = "Origin access control for s3 bucket ${module.s3.s3_bucket_id}"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    ctCustomerAppBucket = {
      domain_name           = module.s3.s3_bucket_bucket_regional_domain_name
      origin_access_control = "${var.app_name}-origin-access-control"
    }
  }

  logging_config = {
    bucket = var.cdn_logging_bucket_name
    prefix = var.app_name
  }

  geo_restriction = {
    restriction_type = "none"
    locations        = []
  }
  ordered_cache_behavior = []

  default_cache_behavior = {
    allowed_methods         = ["GET", "HEAD", "OPTIONS"]
    cached_methods          = ["GET", "HEAD"]
    compress                = true
    query_string            = true
    target_origin_id        = "ctCustomerAppBucket"
    query_string_cache_keys = []
    cookies_forward         = "none"
    headers = [
      "Access-Control-Request-Headers",
      "Access-Control-Request-Method",
      "Origin"
    ]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.rewrite_sub_folder_index.arn
      }
    }
  }

  custom_error_response = [
    {
      error_caching_min_ttl = 300
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    },
    {
      error_caching_min_ttl = 300
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
  }]

  viewer_certificate = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

module "s3" {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=v3.15.1"

  create_bucket = length(var.applications) > 0
  bucket        = var.bucket_name
  tags          = var.tags

  acl                  = "private"
  attach_public_policy = false

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = module.s3.s3_bucket_id
  policy = data.aws_iam_policy_document.cloudfront.json
}

data "aws_iam_policy_document" "cloudfront" {
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
