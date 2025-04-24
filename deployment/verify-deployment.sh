#!/bin/bash
# verify-deployment.sh - Script pentru verificarea deployment-ului Apigee
# Acest script ajută la verificarea și testarea deployment-ului Apigee API Gateway

# Directorul de lucru este repository-ul schoolbus-api-gateway
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$DIR/.." && pwd )"

echo "=== Verificare Deployment Apigee API Gateway ==="

# Solicită informații despre mediul Apigee
read -p "Introdu numele organizației Apigee: " ORG_NAME
read -p "Introdu numele mediului Apigee (ex: dev): " ENV_NAME

# Verifică organizația și mediul Apigee
echo "Verificare organizație Apigee..."
if ! gcloud apigee organizations describe "$ORG_NAME" &> /dev/null; then
  echo "Eroare: Organizația Apigee '$ORG_NAME' nu există sau nu ai permisiuni de acces."
  exit 1
fi

echo "Verificare mediu Apigee..."
if ! gcloud apigee environments describe --organization="$ORG_NAME" "$ENV_NAME" &> /dev/null; then
  echo "Eroare: Mediul Apigee '$ENV_NAME' nu există în organizația '$ORG_NAME'."
  exit 1
fi

# Listează deployment-urile
echo "Deployment-uri existente în mediul '$ENV_NAME':"
gcloud apigee deployments list --environment="$ENV_NAME" --organization="$ORG_NAME"

# Verifică hostnames pentru API Gateway
echo "Verificare hostnames pentru API Gateway..."
ENV_GROUP="${ENV_NAME}-group"
HOSTNAMES=$(gcloud apigee envgroups hostnames list --environment-group="$ENV_GROUP" --organization="$ORG_NAME" --format="value(hostnames)")

if [ -z "$HOSTNAMES" ]; then
  echo "Avertisment: Nu s-au găsit hostname-uri pentru grupul de medii '$ENV_GROUP'."
  echo "Este posibil să fie nevoie să configurezi manual hostname-uri în consola Apigee."
else
  echo "Hostname-uri disponibile: $HOSTNAMES"
  
  # Setare URL Gateway
  GATEWAY_URL=$(echo $HOSTNAMES | cut -d' ' -f1)
  echo "URL Gateway: $GATEWAY_URL"
  
  # Testare endpoint-uri
  echo "Dorești să testezi endpoint-urile API Gateway? (y/n)"
  read TEST_ENDPOINTS
  
  if [[ $TEST_ENDPOINTS == "y" ]]; then
    # Test endpoint health
    echo "Testing /schoolbus/health..."
    curl -s -o /dev/null -w "Status Code: %{http_code}\n" "https://$GATEWAY_URL/schoolbus/health"
    
    # Test endpoint auth
    echo "Testing /schoolbus/api/v1/auth/login..."
    curl -s -X POST "https://$GATEWAY_URL/schoolbus/api/v1/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"email":"test@example.com","password":"password"}' | head -c 300
    echo "..."
    
    # Test endpoint schools
    echo "Testing /schoolbus/api/v1/schools..."
    curl -s -X GET "https://$GATEWAY_URL/schoolbus/api/v1/schools" | head -c 300
    echo "..."
  fi
fi

echo ""
echo "=== Verificare completă ==="
echo "Poți accesa consola Apigee pentru mai multe detalii:"
echo "https://console.cloud.google.com/apigee/proxies?project=$(gcloud config get-value project)" 