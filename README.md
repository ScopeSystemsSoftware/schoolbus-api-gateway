# SchoolBus API Gateway

API Gateway for the SchoolBus Management Platform using Google Apigee. This gateway serves as the entry point for all client applications and manages routing to the underlying microservices.

## Features

- API Gateway for all SchoolBus microservices
- Centralized authentication and authorization
- Rate limiting and request throttling
- Request validation and transformation
- Analytics and monitoring
- API versioning and lifecycle management

## Architecture

The gateway interfaces with the following microservices:
- Auth Service - For user authentication and management
- School Service - For school-related operations
- Additional services will be added as the platform grows

## API Proxy Configuration

The gateway is built using Apigee API Management. The configuration follows a proxy-based approach:

```
/
├── apiproxy/
│   ├── proxies/
│   │   ├── default.xml           # Main proxy endpoint configuration
│   │   ├── auth-service.xml      # Auth service-specific proxy
│   │   └── school-service.xml    # School service-specific proxy
│   ├── resources/
│   │   ├── jsc/                  # JavaScript resources
│   │   ├── node/                 # Node.js resources
│   │   └── xsl/                  # XSLT resources
│   ├── policies/
│   │   ├── Auth-JWT-Verify.xml   # JWT verification policy
│   │   ├── Quota-Rate-Limit.xml  # Rate limiting policy
│   │   └── Response-CORS.xml     # CORS policy
│   ├── targets/
│   │   ├── auth-service.xml      # Auth service target configuration
│   │   └── school-service.xml    # School service target configuration
│   └── manifest.json             # API proxy manifest
└── deployment/
    └── terraform/                # Infrastructure as code
```

## Endpoints

The gateway exposes the following API endpoint categories:

### Auth Service Endpoints
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/firebase-login`
- `POST /api/v1/auth/refresh-token`
- `GET /api/v1/auth/profile`
- `GET /api/v1/users`
- `GET /api/v1/users/:id`
- `POST /api/v1/users`
- `PATCH /api/v1/users/:id`
- `DELETE /api/v1/users/:id`

### School Service Endpoints
- `GET /api/v1/schools`
- `GET /api/v1/schools/:id`
- `POST /api/v1/schools`
- `PATCH /api/v1/schools/:id`
- `DELETE /api/v1/schools/:id`

## Security

The gateway implements the following security measures:
- JWT-based authentication
- Role-based access control
- OAuth 2.0 and OpenID Connect integration
- IP allowlisting
- Request payload validation
- TLS/SSL encryption

## Deployment

The gateway can be deployed to Apigee using the following approaches:
- Apigee Management API
- Apigee CLI
- Terraform (recommended)
- Continuous Integration (CI/CD) pipelines

## Setup

### Prerequisites
- Google Cloud Platform account with Apigee enabled
- Terraform CLI (version 0.14+)
- Google Cloud SDK

### Deployment Steps
1. Configure environment variables
2. Initialize Terraform: `terraform init`
3. Plan deployment: `terraform plan`
4. Apply configuration: `terraform apply`

## Monitoring and Analytics

Apigee provides built-in analytics that can be accessed through:
- Apigee Analytics UI
- Google Cloud Operations (formerly Stackdriver)
- Custom dashboards via API

## Development

For local development and testing, you can use the Apigee mock target server:
```bash
npm install -g apigeetool
apigeetool deployproxy -u {username} -p {password} -o {org} -e {env} -n schoolbus-api -d ./apiproxy
```

## Ghid detaliat pentru dezvoltatori

Acest ghid oferă instrucțiuni pas cu pas pentru configurarea și deployarea Apigee API Gateway pentru platforma SchoolBus Management, astfel încât să ruteze corect către microserviciile de autentificare, școli și celelalte microservicii din arhitectură.

### 1. Pregătirea mediului

Acești pași trebuie executați o singură dată pentru configurarea inițială:

```bash
# Instalare utilitare necesare
gcloud components install beta
npm install -g apigeetool

# Autentificare la Google Cloud
gcloud auth login
gcloud config set project <ID_PROIECT_GCP>

# Activare APIs necesare în proiectul GCP
gcloud services enable \
  apigee.googleapis.com \
  apigeeregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com
```

### 2. Generarea bundle-ului API Proxy

Apigee necesită un bundle ZIP cu configurația proxy-ului:

```bash
# Clonare repository (dacă nu l-ați clonat deja)
git clone https://github.com/ScopeSystemsSoftware/schoolbus-api-gateway.git
cd schoolbus-api-gateway

# Crearea unui director pentru bundle
mkdir -p bundle

# Crearea arhivei ZIP cu conținutul directorului apiproxy
zip -r bundle/schoolbus-api.zip apiproxy/*
```

### 3. Crearea unui bucket pentru stocarea bundle-ului și stare Terraform

```bash
# Crearea bucketului pentru bundle-uri (numele trebuie să fie unic global)
BUCKET_NAME="schoolbus-apigee-$(date +%s)"
gcloud storage buckets create gs://$BUCKET_NAME

# Încărcarea bundle-ului în bucket
gcloud storage cp bundle/schoolbus-api.zip gs://$BUCKET_NAME/
```

### 4. Ajustarea fișierelor Terraform

Fișierul `main.tf` face referire la un bucket care nu există, trebuie actualizat:

```bash
# Editează fișierul main.tf pentru a actualiza bucket-ul pentru backend
sed -i '' "s/schoolbus-terraform-state/$BUCKET_NAME/g" deployment/terraform/main.tf

# Editează fișierul main.tf pentru a actualiza calea bundle-ului
sed -i '' "s|gs://schoolbus-apigee-bundles/schoolbus-api.zip|gs://$BUCKET_NAME/schoolbus-api.zip|g" deployment/terraform/main.tf
```

Alternativ, puteți edita manual aceste fișiere.

### 5. Configurarea variabilelor Terraform

```bash
# Creează fișierul terraform.tfvars din exemplu
cd deployment/terraform
cp terraform.tfvars.example terraform.tfvars

# Editează terraform.tfvars cu valorile corecte
# project_id = ID-ul proiectului tău GCP
# region = regiunea dorită (e.g., "europe-west1")
# environment = mediul (dev, test, prod)
# proxy_bundle_path = gs://$BUCKET_NAME/schoolbus-api.zip
```

Exemplu de conținut pentru `terraform.tfvars`:
```
project_id      = "schoolbus-platform-12345"
region          = "europe-west1"
environment     = "dev"
proxy_bundle_path = "gs://schoolbus-apigee-12345/schoolbus-api.zip"
```

### 6. Ajustarea adreselor microserviciilor

Înainte de deployment, trebuie să specificați adresele corecte ale microserviciilor:

```bash
# Pentru auth-service
vi apiproxy/targets/auth-service.xml

# Pentru school-service
vi apiproxy/targets/school-service.xml
```

Modificați liniile cu URL-urile pentru a reflecta adresele reale ale microserviciilor:

```xml
<!-- Pentru auth-service.xml -->
<URL>https://auth-service.endpoints.your-project-id.cloud.goog</URL>

<!-- Pentru school-service.xml -->
<URL>https://school-service.endpoints.your-project-id.cloud.goog</URL>
```

Apoi regenerați bundle-ul ZIP și reîncărcați-l în bucket:

```bash
zip -r bundle/schoolbus-api.zip apiproxy/*
gcloud storage cp bundle/schoolbus-api.zip gs://$BUCKET_NAME/
```

### 7. Rularea Terraform

```bash
# Întoarceți-vă în directorul terraform (dacă nu sunteți deja acolo)
cd deployment/terraform

# Inițializare Terraform
terraform init

# Verificare plan (revizuiți modificările propuse)
terraform plan

# Aplicare configurație
terraform apply
```

Acest proces poate dura între 15-30 minute pentru crearea organizației Apigee și a tuturor resurselor necesare.

### 8. Verificarea deployment-ului

După ce Terraform termină de rulat:

```bash
# Verificare organizație Apigee
gcloud apigee organizations list

# Verificare medii Apigee
gcloud apigee environments list --organization=YOUR_ORG_NAME

# Verificare deployments
gcloud apigee deployments list --organization=YOUR_ORG_NAME
```

### 9. Testarea API Gateway

Odată ce gateway-ul este deployat, puteți testa endpoint-urile:

```bash
# Obțineți adresa API Gateway
GATEWAY_URL=$(gcloud apigee envgroups hostnames list \
  --environment-group=${var.environment}-group \
  --organization=YOUR_ORG_NAME \
  --format="value(hostnames[0])")

# Testarea unui endpoint (ex. serviciul de autentificare)
curl -X POST "https://$GATEWAY_URL/schoolbus/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Probleme cunoscute și soluții

#### Problema 1: Eroare la crearea organizației Apigee
**Soluție**: Asigurați-vă că factoring-ul este activat pentru proiect și că aveți permisiunile necesare.

#### Problema 2: Eroare la upload bundle
**Soluție**: Verificați permisiunile bucket-ului și asigurați-vă că bundle-ul ZIP este valid.

#### Problema 3: Terraformul se blochează la creare resurse
**Soluție**: Apigee poate lua timp să se inițializeze, până la 30 minute. Așteptați și verificați statusul în consola GCP.

#### Problema 4: Eroare de conectare la microservicii
**Soluție**: Verificați adresele microserviciilor în fișierele target XML și asigurați-vă că microserviciile sunt accesibile.

### Resurse adiționale

- [Documentația oficială Apigee](https://cloud.google.com/apigee/docs)
- [Terraform Provider pentru Apigee](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_organization)
- [Apigee API Reference](https://cloud.google.com/apigee/docs/reference)