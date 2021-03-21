remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${get_env("BUCKET")}"
    
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
  }
}