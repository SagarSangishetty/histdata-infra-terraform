resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_subject]
    }
  }
}

resource "aws_iam_role" "github_terraform" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.github_assume_role.json
  max_session_duration = 3600
}

# This broad policy is temporary for the isolated learning account.
# Replace it with a custom least-privilege policy before treating this
# configuration as a production security baseline.
resource "aws_iam_role_policy_attachment" "administrator" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
