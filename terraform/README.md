#### create the project and initialize gcloud sdk
export GOOGLE_PROJECT_ID=${your project id}

#### enable required apis:
```shell script
gcloud config set project ${GOOGLE_PROJECT_ID}
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
gcloud iam service-accounts create terraform --display-name="Terraform CI"
gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} --member serviceAccount:terraform@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com --role roles/editor
gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} --member serviceAccount:terraform@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com --role roles/compute.networkAdmin
gcloud iam service-accounts keys create berlioz-credentials.json --iam-account=terraform@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com
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
In order to have it correctly working DNS name should be matched to ingress ip address. This will allow to pass acme challenge.

#### trigger configuration manually
- build app and web docker images and push them to GCR
- initialize terraform

export GOOGLE_PROJECT_ID="gcp-project-id"
export GOOGLE_COMPUTE_REGION="gcp-region"
export GOOGLE_CREDENTIALS="contents-of-service-account-credentials"
export CIRCLE_SHA1="some-sha"
export TF_STATE_GCS_BUCKET="gcp-storage-bucket-name"

```shell script
cd terraform
terraform init -backend-config=bucket="${TF_STATE_GCS_BUCKET}" -backend-config=prefix="terraform/state"
terraform plan -var app_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-app:${CIRCLE_SHA1} -var web_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-web:${CIRCLE_SHA1} -var gcp_project_id=${GOOGLE_PROJECT_ID} -var gcp_region=${GOOGLE_COMPUTE_REGION}
terraform refresh -var app_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-app:${CIRCLE_SHA1} -var web_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-web:${CIRCLE_SHA1} -var gcp_project_id=${GOOGLE_PROJECT_ID} -var gcp_region=${GOOGLE_COMPUTE_REGION}
terraform apply --auto-approve -var app_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-app:${CIRCLE_SHA1} -var web_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-web:${CIRCLE_SHA1} -var gcp_project_id=${GOOGLE_PROJECT_ID} -var gcp_region=${GOOGLE_COMPUTE_REGION}
terraform destroy --auto-approve  -var app_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-app:${CIRCLE_SHA1} -var web_image=us.gcr.io/${GOOGLE_PROJECT_ID}/berlioz-web:${CIRCLE_SHA1} -var gcp_project_id=${GOOGLE_PROJECT_ID} -var gcp_region=${GOOGLE_COMPUTE_REGION}```

