#### create the project and initialize gcloud sdk
#### enable required apis:
```shell script
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable container.googleapis.com
```
#### create service account and generate the access token
Use the name and display name you prefer (the name is terraform in the example)
```shell script
export gcp_project_id=${your project id}
gcloud iam service-accounts create terraform --display-name="Terraform CI"
gcloud projects add-iam-policy-binding ${gcp_project_id} --member serviceAccount:terraform@${gcp_project_id}.iam.gserviceaccount.com --role roles/editor
gcloud projects add-iam-policy-binding ${gcp_project_id} --member serviceAccount:terraform@${gcp_project_id}.iam.gserviceaccount.com --role roles/compute.networkAdmin
gcloud iam service-accounts keys create ~/berlioz.json --iam-account=terraform@${gcp_project_id}.iam.gserviceaccount.com
```
#### create GCS bucket for terraform state
```shell script
gsutil mb gs://terraform-berlioz-state
```
#### configure CircleCI context
Create the context named *staging* in CircleCI and populate it with the following variables:
```
GCLOUD_SERVICE_KEY = ${the content of berlioz.json file}
GOOGLE_COMPUTE_REGION = ${GCP region, us-central1 for example}
GOOGLE_COMPUTE_ZONE = ${GCP zone, us-central1-a for example}
GOOGLE_PROJECT_ID = ${GCP project id}
TF_STATE_GCS_BUCKET = ${bucket name from the previuous step without gs://, terraform-berlioz-state in the example}
TF_VAR_https_hostname = https hostname (OPTIONAL)
```
If TF_VAR_https_hostname is defined then terraform will create GCP managed let's encrypt certificate and apply it for the ingress. Ingress will be configured as https load-balancer with disabled http.
#### trigger configuration manually
- build app and web docker images and push them to GCR
- initialize terraform
```shell script
cd terraform
terraform init -backend-config=bucket="terraform-berlioz-state" -backend-config=prefix="terraform/state"
terraform apply terraform plan -var app_image=us.gcr.io/berlioz-255809/berlioz@sha256:2e4e03b4f5dbc38eea40c3e2dc18d0ff1b4130124ae2d436381f5190f84b1d0b -var web_image=us.gcr.io/berlioz-255809/berlioz@sha256:421f14a1a30ae68d26c5cd1f1263fa6db2262f2336a6671d48584ade1eeca2c3 -var gcp_project_id=berlioz-255809 -var gcp_region=us-central1
```

