data "aws_resourcegroupstaggingapi_resources" "ingress" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "kubernetes.io/service-name"
    values = ["${var.client}/${var.client}-${var.environment}-ingress-nginx-controller"]
  }
}

data "aws_elb" "ingress" {
  name = element(split("/", data.aws_resourcegroupstaggingapi_resources.ingress.resource_tag_mapping_list[0].resource_arn), length(data.aws_resourcegroupstaggingapi_resources.ingress.resource_tag_mapping_list[0].resource_arn))
}

data "aws_route53_zone" "demo" {
  name         = "${var.domain}."
  private_zone = false
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.client}-${var.environment}-cloudfront-logs"

  tags = var.tags
}

resource "aws_s3_bucket_acl" "cloudfront_logs_acl" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"
}

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  # aliases = ["${local.subdomain}.${local.domain_name}"]
  aliases = []

  comment             = "EKS CDN"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_monitoring_subscription = false

  logging_config = {
    bucket = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix = "cloudfront"
  }

  origin = {
    eks = {
      domain_name = data.aws_elb.ingress.dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "eks"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true

    # This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }
}
