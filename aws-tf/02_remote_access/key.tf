resource "aws_key_pair" "doorward" {
  key_name   = "doorward"
  public_key = file('.env/doorward.pem')
}

