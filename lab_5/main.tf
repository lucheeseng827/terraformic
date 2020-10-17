provider "docker" {
    host = "tcp://192.168.50.130:2376/"

}

resource "docker_container" "flask" {
    image = "debian:latest"
    name = "flasky"
}

resource "docker_image" "ubuntu" {
    name = "ubuntu:latest"
}


#more on registry credential

