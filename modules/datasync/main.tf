data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3" {
  count              = var.enabled ? 1 : 0
  name               = "${var.name}-datasync-s3"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "s3" {
  count = var.enabled ? 1 : 0
  name  = "write-historical-data"
  role  = aws_iam_role.s3[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
        Resource = var.s3_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:ListMultipartUploadParts",
          "s3:PutObject", "s3:GetObjectTagging", "s3:PutObjectTagging"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_datasync_location_nfs" "source" {
  count          = var.enabled ? 1 : 0
  server_hostname = var.nfs_server_hostname
  subdirectory    = var.nfs_subdirectory
  on_prem_config { agent_arns = [var.agent_arn] }
  mount_options { version = "AUTOMATIC" }
  tags = var.tags
}

resource "aws_datasync_location_s3" "destination" {
  count         = var.enabled ? 1 : 0
  s3_bucket_arn = var.s3_bucket_arn
  subdirectory  = "/"
  s3_config { bucket_access_role_arn = aws_iam_role.s3[0].arn }
  tags = var.tags
}

resource "aws_datasync_task" "this" {
  count                    = var.enabled ? 1 : 0
  name                     = "${var.name}-onprem-to-s3"
  source_location_arn      = aws_datasync_location_nfs.source[0].arn
  destination_location_arn = aws_datasync_location_s3.destination[0].arn

  options {
    verify_mode            = "ONLY_FILES_TRANSFERRED"
    overwrite_mode         = "ALWAYS"
    preserve_deleted_files = "PRESERVE"
    transfer_mode          = "CHANGED"
  }
  schedule { schedule_expression = var.schedule_expression }
  tags = var.tags
}
