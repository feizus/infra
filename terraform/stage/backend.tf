resource "google_storage_bucket" "bucket_stage" {
  name     = "${var.bucket_name}"
  storage_class = "COLDLINE"
  location = "europe-west1"
  force_destroy = true
}

resource "google_storage_bucket_object" "my_files" {
  name   = "terraform.tfstate"
  source = "terraform.tfstate"
  bucket = "${google_storage_bucket.bucket_stage.name}"
}

variable "bucket_name" {
  default = "feizus-infra-hw9-stage"
}