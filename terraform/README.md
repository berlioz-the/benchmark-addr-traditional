


gcloud services enable compute.googleapis.com
gcloud iam service-accounts create terraform --display-name="Terraform CI"
gcloud projects add-iam-policy-binding berlioz-255809 --member serviceAccount:terraform@berlioz-255809.iam.gserviceaccount.com --role roles/editor
gsutil mb gs://terraform-berlioz-state
