resource "aws_s3_bucket" "test" {
  bucket = "test-bucket71717"
}

resource "aws_iam_role" "trust_relationship" {
  name = "trust_relationship"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_provider}:aud" : "sts.amazonaws.com",
            "${local.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account}"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy" "test_s3" {
  name = "test-s3"
  role = aws_iam_role.trust_relationship.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : aws_s3_bucket.test.arn
      }
    ]
  })
}
