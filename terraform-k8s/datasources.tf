data "terraform_remote_state" "kubeconfig" {
  backend = "remote"

  config = {
    organization = "Imminent"
    workspaces = {
      name = "mtc-dev"
    }
  }
}