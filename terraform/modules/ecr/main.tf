data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "api" {
  name = "${var.client}/api"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "api_policy" {
  repository = aws_ecr_repository.api.name
  policy     = file("${path.module}/lifecycle-policy.json")
}

resource "aws_ecr_repository" "web" {
  name = "${var.client}/web"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "web_policy" {
  repository = aws_ecr_repository.web.name
  policy     = file("${path.module}/lifecycle-policy.json")
}


data "aws_iam_policy_document" "ecr_read_and_write_perms" {
  statement {
    sid = "ECRWrite"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalAccount"#"aws:PrincipalOrgID"
      values   = [data.aws_caller_identity.current.account_id]#[var.organization_id]
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
    ]
  }
}

resource "aws_ecr_repository_policy" "web" {
  repository = aws_ecr_repository.web.name
  policy = data.aws_iam_policy_document.ecr_read_and_write_perms.json
}

resource "aws_ecr_repository_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy = data.aws_iam_policy_document.ecr_read_and_write_perms.json
}
