resource "google_compute_instance" "db" {
    name = "reddit-db"
    machine_type = "f1-micro"
    zone = "${var.zone}"
    tags = ["reddit-db"]
    boot_disk {
        initialize_params {
            image = "${var.db_disk_image}"
        }
    }
    network_interface {
        network = "default"
        access_config = {}
    }
    metadata {
        ssh-keys = "appuser:${file(var.public_key_path)}"
    }
}

