terraform {
  backend "remote" {
    organization = "appify"
    workspaces {
      name = "appify"
    }
  }
}
