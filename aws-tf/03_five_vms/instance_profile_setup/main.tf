variable "s3_bucket" {
  type = string
}
variable "bucket_role_name" {
  type = string
}
variable "bucket_policy_name" {
  type = string
}
variable "instance_profile_name" {
  type = string
}


# Creating the IAM policy for access to S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = var.bucket_policy_name
  description = "Policy to allow access to S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      }
    ]
  })
}
# Creating the IAM role
resource "aws_iam_role" "ec2_role" {
  name               = var.bucket_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}
# Binding the policy to the role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_role.name
}
# Create instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_role.name
}