terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Provider docker avec un hôte local
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Image construite depuis le dossier contenant le Dockerfile
resource "docker_image" "build" {
  name = "fastapi-app:latest"

  build {
    context = "${path.module}/../app"
  }

  # Reconstruit l'image si un fichier de app/ change
  triggers = {
    dir_sha1 = sha1(join("", [
      for f in fileset("${path.module}/../app", "**") :
      filesha1("${path.module}/../app/${f}")
    ]))
  }
}

# Container lancé à partir de l'image "build"
resource "docker_container" "container" {
  name  = "fastapi-app"
  image = docker_image.build.image_id

  ports {
    internal = 8000
    external = 8080
  }
}
