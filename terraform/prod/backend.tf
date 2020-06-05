resource "google_storage_bucket" "bucket_prod" {
  name     = "${var.bucket_name}"
  storage_class = "COLDLINE"
  location = "europe-west1"
  force_destroy = true
}

resource "google_storage_bucket_object" "my_files" {
  name   = "terraform.tfstate"
  source = "terraform.tfstate"
  bucket = "${google_storage_bucket.bucket_prod.name}"
}

# resource "google_storage_bucket_object" "public_key" {
#   name   = "appuser.pub"
#   source = "/home/ps/.ssh/appuser.pub"
#   bucket = "${google_storage_bucket.bucket.name}"
# }

variable "bucket_name" {
  default = "feizus-infra-hw9-prod"
}
