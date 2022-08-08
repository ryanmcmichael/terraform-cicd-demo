data "aws_iam_policy" "AmazonEC2ContainerRegistryPowerUser" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_user" "user" {
  name = "${var.environment}-${var.client}-github-actions"
  path = "/"
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.user.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryPowerUser.arn
}
