locals {
  s3_bucket_name                        = "${var.product}-${var.service}-${var.environment}-${var.target}-frontend-application-bucket"
  cloudfront_s3_origin_id               = "${var.target}-frontend-s3-origin"
  cloudfront_lb_origin_id               = "${var.target}-bff-lb-origin"
  cloudfront_origin_access_control_name = "${var.product}-${var.service}-${var.environment}-${var.target}-frontend-application-cloudfront-oac"
  cloudfront_function_name              = "${var.product}-${var.service}-${var.environment}-${var.target}-frontend-basic-auth-function"
  created_bff_lb_origin_and_behavior    = length(var.cloudfront_bff_lb_origin_domain_name) != 0
}

resource "aws_s3_bucket" "main" {
  bucket = local.s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allowe_access_from_cloudfront" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = local.cloudfront_s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  dynamic "origin" {
    for_each = local.created_bff_lb_origin_and_behavior ? [1] : []
    content {
      domain_name = var.cloudfront_bff_lb_origin_domain_name
      origin_id   = local.cloudfront_lb_origin_id
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "qb ${var.service} ${var.environment} ${var.target} frontend application distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    # Using the CachingOptimized managed policy ID:
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    # Using the CORS-S3Origin managed policy ID:
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    # Using the Managed-CORS-with-preflight-and-SecurityHeadersPolicy managed policy ID:
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.cloudfront_s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.main.arn
    }
  }

  # Cache behavior with precedence 0
  dynamic "ordered_cache_behavior" {
    for_each = local.created_bff_lb_origin_and_behavior ? [1] : []
    content {
      path_pattern           = "/api/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = local.cloudfront_lb_origin_id
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      # Using the CachingDisabled managed policy ID:
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      # Using the AllViewers managed policy ID:
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    }
  }

  # Cache behavior with precedence 1
  dynamic "ordered_cache_behavior" {
    for_each = local.created_bff_lb_origin_and_behavior ? [1] : []
    content {
      path_pattern           = "/oauth2/authorization/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = local.cloudfront_lb_origin_id
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      # Using the CachingDisabled managed policy ID:
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      # Using the AllViewers managed policy ID:
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    }
  }

  # Cache behavior with precedence 2
  dynamic "ordered_cache_behavior" {
    for_each = local.created_bff_lb_origin_and_behavior ? [1] : []
    content {
      path_pattern           = "/login/oauth2/code/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = local.cloudfront_lb_origin_id
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      # Using the CachingDisabled managed policy ID:
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      # Using the AllViewers managed policy ID:
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    }
  }

  # Cache behavior with precedence 3
  dynamic "ordered_cache_behavior" {
    for_each = local.created_bff_lb_origin_and_behavior ? [1] : []
    content {
      path_pattern           = "/logout"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = local.cloudfront_lb_origin_id
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      # Using the CachingDisabled managed policy ID:
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      # Using the AllViewers managed policy ID:
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = local.cloudfront_origin_access_control_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "main" {
  name    = local.cloudfront_function_name
  runtime = "cloudfront-js-1.0"
  comment = "basic auth and fetch index html file for ${var.target} frontend"
  publish = true
  code = templatefile("${path.module}/templates/basic-authentication-and-fetch-index-html-file.js.tftpl", {
    enable_basic_authentication = var.basic_authentication.enabled
    basic_auth_token            = base64encode("${var.basic_authentication.user_id}:${var.basic_authentication.password}")
  })
}