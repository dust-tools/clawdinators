data "aws_caller_identity" "current" {}

locals {
  pr_intent_bucket_name = var.pr_intent_bucket_name != "" ? var.pr_intent_bucket_name : "openclaw-pr-intent-${data.aws_caller_identity.current.account_id}"
}

# Public bucket hosting PR intent artifacts (anonymous read + list).
resource "aws_s3_bucket" "pr_intent_public" {
  bucket = local.pr_intent_bucket_name
  tags   = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

# Allow bucket policy to grant public access (but keep ACL-based public access blocked).
resource "aws_s3_bucket_public_access_block" "pr_intent_public" {
  bucket = aws_s3_bucket.pr_intent_public.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "pr_intent_public" {
  bucket = aws_s3_bucket.pr_intent_public.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pr_intent_public" {
  bucket = aws_s3_bucket.pr_intent_public.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "pr_intent_public" {
  bucket = aws_s3_bucket.pr_intent_public.id

  versioning_configuration {
    status = var.pr_intent_bucket_versioning_enabled ? "Enabled" : "Suspended"
  }
}

data "aws_iam_policy_document" "pr_intent_public_bucket_policy" {
  statement {
    sid     = "AnonymousList"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.pr_intent_public.arn
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "AnonymousRead"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.pr_intent_public.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "pr_intent_public" {
  bucket = aws_s3_bucket.pr_intent_public.id
  policy = data.aws_iam_policy_document.pr_intent_public_bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.pr_intent_public]
}

# Allow CLAWDINATOR instances to publish artifacts into the public bucket.
# (No DeleteObject by default; we publish new/updated files only.)
data "aws_iam_policy_document" "instance_pr_intent_publish" {
  statement {
    sid = "PublishPrIntentArtifacts"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:CreateMultipartUpload",
      "s3:UploadPart",
      "s3:CompleteMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.pr_intent_public.arn}/*"
    ]
  }

  statement {
    sid       = "BucketLocation"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.pr_intent_public.arn]
  }
}

resource "aws_iam_role_policy" "instance_pr_intent_publish" {
  name   = "clawdinator-pr-intent-publish"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.instance_pr_intent_publish.json
}
