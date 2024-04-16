resource "aws_kms_key" "interop_client_key" {
  description              = "KMS key for Interop API"
  deletion_window_in_days  = 7
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
}

data "aws_iam_policy_document" "kms_access" {

  statement {
    sid    = "AllowKMSUse"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
      "kms:GenerateMac",
      "kms:GenerateRandom",
      "kms:Verify",
      "kms:VerifyMac"
    ]
    resources = [
      aws_kms_key.interop_client_key.arn
    ]
  }
}

resource "aws_iam_policy" "kms_access" {
  name        = "${local.project}-kmsuse-policy"
  description = "Policy to allow use of KMS Key"
  policy      = data.aws_iam_policy_document.kms_access.json
}

// TODO assign policy to k8s service account

