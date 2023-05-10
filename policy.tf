resource "aws_iam_role_policy" "test" {
  name = "test-s3"
  role = module.cluster.trust_role
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}
