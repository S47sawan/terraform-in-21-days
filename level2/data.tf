data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "s3-backend-state-bucket-27"
    key    = "level1.tfstate"
    region = "eu-west-2"
  }
}

