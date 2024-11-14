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


# Getting information about the existing S3 bucket
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.s3_bucket
}

# Getting information about the existing IAM policy
# data "aws_iam_policy" "existing_s3_policy" {
#   name = var.bucket_policy_name
# }

# Getting information about the existing IAM role
data "aws_iam_role" "existing_s3_role" {
  name = var.bucket_role_name
}

# Binding the existing policy to the role
# resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
#   policy_arn = data.aws_iam_policy.existing_s3_policy.arn
#   role       = data.aws_iam_role.existing_s3_role.name
# }

# Create instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name
  role = data.aws_iam_role.existing_s3_role.name
}


output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}
output "instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_instance_profile.arn
}
