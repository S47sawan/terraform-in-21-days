data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "s3-backend-state-bucket-270"
    key    = "level1.tfstate"
    region = "us-east-1"
  }
}
