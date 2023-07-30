resource "aws_s3_bucket" "example" {
  bucket = "s3-backend-state-bucket-270"

  tags = {
    Name = "${var.env_code}-s3-backend-state-bucket-270"
  }
}
resource "aws_dynamodb_table" "state-lock" {
  name         = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"


  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "${var.env_code}-state-lock"
  }
}
