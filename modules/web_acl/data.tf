#######################################################
# Remote state outputs from tf-load-balancers project
#######################################################

data "terraform_remote_state" "external_load_balancer" {
  for_each  = toset(var.environments)
  backend   = "s3"
  workspace = "${each.key}-${var.stage}"
  config = {
    bucket         = "youlend-terraform-backend"
    key            = "tf-load-balancers.tfstate"
    region         = "eu-west-1"
    encrypt        = true #AES-256 encryption
    dynamodb_table = "youlend-terraform-locks"
  }
}