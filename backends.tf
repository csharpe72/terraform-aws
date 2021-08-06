terraform {
  backend "remote" {
    organization = "Imminent"

    workspaces {
      name = "mtc-dev"
    }
  }
}