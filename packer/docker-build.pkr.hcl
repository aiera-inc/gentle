packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "gentle" {
  image     = "121356702072.dkr.ecr.us-east-1.amazonaws.com/gentle:latest"
  commit    = true
  ecr_login = true
  login     = "https://121356702072.dkr.ecr.us-east-1.amazonaws.com/"
}

build {
  sources = ["source.docker.gentle"]
}

