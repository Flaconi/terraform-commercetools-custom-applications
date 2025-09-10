# terraform-commercetools-custom-applications
Module to setup cloudfront, s3 and ssm for custom applications

[![lint](https://github.com/flaconi/terraform-commercetools-custom-applications/workflows/lint/badge.svg)](https://github.com/flaconi/terraform-commercetools-custom-applications/actions?query=workflow%3Alint)
[![test](https://github.com/flaconi/terraform-commercetools-custom-applications/workflows/test/badge.svg)](https://github.com/flaconi/terraform-commercetools-custom-applications/actions?query=workflow%3Atest)
[![Tag](https://img.shields.io/github/tag/flaconi/terraform-commercetools-custom-applications.svg)](https://github.com/flaconi/terraform-commercetools-custom-applications/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

<!-- TFDOCS_REQUIREMENTS_END -->

<!-- TFDOCS_INPUTS_START -->
## Required Inputs

The following input variables are required:

### <a name="input_app_name"></a> [app\_name](#input\_app\_name)

Description: application name

Type: `string`

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: name of the bucket to used to upload the custom application

Type: `string`

### <a name="input_cdn_logging_bucket_name"></a> [cdn\_logging\_bucket\_name](#input\_cdn\_logging\_bucket\_name)

Description: bucket where the cloudfront logs will be send to

Type: `string`

### <a name="input_ssm_name_prefix"></a> [ssm\_name\_prefix](#input\_ssm\_name\_prefix)

Description: prefix for the ssm path for each custom application

Type: `string`

### <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id)

Description: aws account id used to build access policy for the cdn to s3

Type: `string`

### <a name="input_applications"></a> [applications](#input\_applications)

Description: map of custom applications to be setup

Type:

```hcl
map(object({
    tags           = optional(map(string), {})
    application_id = string
    additional_ssm_parameters = optional(list(object({
      name  = string
      type  = optional(string, "SecureString") # String, StringList or SecureString
      value = string
    })), [])
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_attach_deny_insecure_transport_policy"></a> [attach\_deny\_insecure\_transport\_policy](#input\_attach\_deny\_insecure\_transport\_policy)

Description: Controls if S3 bucket should have deny non-SSL transport policy attached

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Map of custom tags for the provisioned resources

Type: `map(string)`

Default: `{}`

<!-- TFDOCS_INPUTS_END -->

<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |

<!-- TFDOCS_OUTPUTS_END -->

## License

**[MIT License](LICENSE)**

Copyright (c) 2023 **[Flaconi GmbH](https://github.com/flaconi)**
