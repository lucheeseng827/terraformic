provider "docker" {
    host = "tcp://192.168.150.139:2376/"

}

resource "docker_container" "flask" {
    image = "debian:latest"
    name = "flasky"
}

resource "docker_image" "ubuntu" {
    name = "ubuntu:latest"
}
