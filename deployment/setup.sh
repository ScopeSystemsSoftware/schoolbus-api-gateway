#!/bin/bash
# setup.sh - Script helper pentru configurarea Apigee API Gateway
# Acest script execută pașii 2-4 din ghidul de dezvoltator:
# - Generează bundle-ul API Proxy
# - Creează un bucket GCS pentru stocarea stării Terraform și a bundle-ului
# - Actualizează fișierele Terraform pentru a referenția corect bucket-ul

# Verifică dacă gcloud și alte dependențe sunt instalate
command -v gcloud >/dev/null 2>&1 || { echo "Error: gcloud CLI nu este instalat"; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "Error: zip nu este instalat"; exit 1; }

# Directorul de lucru este repository-ul schoolbus-api-gateway
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$DIR/.." && pwd )"

echo "=== SchoolBus API Gateway Setup ==="
echo "Director repository: $REPO_ROOT"

# Pas 1: Verifică dacă utilizatorul este autentificat la Google Cloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
  echo "Eroare: Nu ești autentificat la Google Cloud. Rulează 'gcloud auth login' întâi."
  exit 1
fi

# Pas 2: Solicită ID-ul proiectului GCP
read -p "Introdu ID-ul proiectului GCP: " PROJECT_ID
gcloud config set project $PROJECT_ID

# Pas 3: Activare APIs necesare (dacă nu sunt deja activate)
echo "Activare APIs necesare..."
gcloud services enable \
  apigee.googleapis.com \
  apigeeregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com

# Pas 4: Crearea directorului pentru bundle
BUNDLE_DIR="$REPO_ROOT/bundle"
mkdir -p $BUNDLE_DIR

# Pas 5: Generare bundle ZIP
echo "Generare bundle API Proxy..."
cd $REPO_ROOT
zip -r $BUNDLE_DIR/schoolbus-api.zip apiproxy/*

# Pas 6: Crearea unui bucket pentru stocarea bundle-ului și stare Terraform
TIMESTAMP=$(date +%s)
BUCKET_NAME="schoolbus-apigee-$TIMESTAMP"
echo "Creare bucket GCS: $BUCKET_NAME"
if gcloud storage buckets create gs://$BUCKET_NAME; then
  echo "Bucket creat cu succes: gs://$BUCKET_NAME"
else
  echo "Eroare la crearea bucket-ului. Se oprește execuția."
  exit 1
fi

# Pas 7: Încărcare bundle în bucket
echo "Încărcare bundle în bucket..."
gcloud storage cp $BUNDLE_DIR/schoolbus-api.zip gs://$BUCKET_NAME/

# Pas 8: Actualizare main.tf cu referințe la bucket-ul nou
echo "Actualizare referințe bucket în fișierele Terraform..."
MAIN_TF="$DIR/terraform/main.tf"
sed -i.bak "s/bucket = \"schoolbus-terraform-state\"/bucket = \"$BUCKET_NAME\"/g" $MAIN_TF
sed -i.bak "s|gs://schoolbus-apigee-bundles/schoolbus-api.zip|gs://$BUCKET_NAME/schoolbus-api.zip|g" $MAIN_TF
rm $MAIN_TF.bak

# Pas 9: Creare terraform.tfvars din exemplu
echo "Creare terraform.tfvars..."
TFVARS="$DIR/terraform/terraform.tfvars"
cp "$DIR/terraform/terraform.tfvars.example" $TFVARS

# Pas 10: Actualizare terraform.tfvars cu valorile corecte
cat > $TFVARS << EOF
project_id      = "$PROJECT_ID"
region          = "us-central1"
environment     = "dev"
proxy_bundle_path = "gs://$BUCKET_NAME/schoolbus-api.zip"
EOF

echo "===== CONFIGURARE COMPLETĂ ====="
echo "Bucket creat: gs://$BUCKET_NAME"
echo "Bundle încărcat: gs://$BUCKET_NAME/schoolbus-api.zip"
echo "Fișierele Terraform au fost actualizate."
echo ""
echo "Pentru a continua, rulează:"
echo "cd $DIR/terraform"
echo "terraform init"
echo "terraform plan"
echo "terraform apply"
echo ""
echo "Notă: Asigură-te că adresele microserviciilor sunt actualizate în fișierele target înainte de deployment!" 