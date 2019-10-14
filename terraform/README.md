1. create the project and activate gcloud sdk
2. enable required apis:
    gcloud services enable compute.googleapis.com
    gcloud services enable servicenetworking.googleapis.com
    gcloud services enable cloudresourcemanager.googleapis.com
3. create service account and generate the access token:
    gcloud iam service-accounts create terraform --display-name="Terraform CI"
    gcloud projects add-iam-policy-binding berlioz-255809 --member serviceAccount:terraform@berlioz-255809.iam.gserviceaccount.com --role roles/editor
    gcloud iam service-accounts keys create ~/berlioz.json --iam-account=terraform@berlioz-255809.iam.gserviceaccount.com
4. create terraform GCS state bucket
    gsutil mb gs://terraform-berlioz-state
5. configure terraform backend in versions.tf and terraform.tfvars
6. apply configuration
    terraform apply -var app_image=${image} -var web_image=${image}
