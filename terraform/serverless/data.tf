data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "ACG-Terraform-Labs-Teste"
    workspaces = {
      name = "lab-migrate-state"
    }
  }
}

data "terraform_remote_state" "database" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "ACG-Terraform-Labs-Teste"
    workspaces = {
      name = "techchallenge-database"
    }
  }
}