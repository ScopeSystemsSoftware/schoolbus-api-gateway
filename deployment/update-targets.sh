#!/bin/bash
# update-targets.sh - Script pentru actualizarea adreselor microserviciilor
# Acest script ajută la actualizarea adreselor microserviciilor în fișierele target XML

# Directorul de lucru este repository-ul schoolbus-api-gateway
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$DIR/.." && pwd )"

echo "=== Actualizare adrese microservicii ==="
echo "Director repository: $REPO_ROOT"

# Solicită informații despre microservicii
read -p "Introdu URL-ul pentru Auth Service (ex: https://auth-service.your-domain.com): " AUTH_URL
read -p "Introdu URL-ul pentru School Service (ex: https://school-service.your-domain.com): " SCHOOL_URL

# Verifică dacă URL-urile sunt valide
if [[ ! $AUTH_URL =~ ^https?:// ]]; then
  echo "Eroare: URL-ul pentru Auth Service trebuie să înceapă cu http:// sau https://"
  exit 1
fi

if [[ ! $SCHOOL_URL =~ ^https?:// ]]; then
  echo "Eroare: URL-ul pentru School Service trebuie să înceapă cu http:// sau https://"
  exit 1
fi

# Actualizează fișierele target XML
AUTH_TARGET="$REPO_ROOT/apiproxy/targets/auth-service.xml"
SCHOOL_TARGET="$REPO_ROOT/apiproxy/targets/school-service.xml"

# Verifică dacă fișierele există
if [ ! -f "$AUTH_TARGET" ] || [ ! -f "$SCHOOL_TARGET" ]; then
  echo "Eroare: Fișierele target nu există. Asigură-te că structura repository-ului este corectă."
  exit 1
fi

# Backup fișiere înainte de modificare
cp "$AUTH_TARGET" "$AUTH_TARGET.bak"
cp "$SCHOOL_TARGET" "$SCHOOL_TARGET.bak"

# Actualizează adresele în fișierele target
echo "Actualizare $AUTH_TARGET..."
sed -i.tmp "s|<URL>.*</URL>|<URL>$AUTH_URL</URL>|g" "$AUTH_TARGET"

echo "Actualizare $SCHOOL_TARGET..."
sed -i.tmp "s|<URL>.*</URL>|<URL>$SCHOOL_URL</URL>|g" "$SCHOOL_TARGET"

# Curățare fișiere temporare
rm "$AUTH_TARGET.tmp" "$SCHOOL_TARGET.tmp"

echo "Adresele microserviciilor au fost actualizate."
echo ""
echo "URL Auth Service: $AUTH_URL"
echo "URL School Service: $SCHOOL_URL"
echo ""
echo "Fișierele originale au fost salvate ca .bak"
echo ""
echo "Pentru a finaliza, trebuie să regenerezi bundle-ul ZIP și să-l reîncarci în bucket:"
echo "cd $REPO_ROOT"
echo "zip -r bundle/schoolbus-api.zip apiproxy/*"
echo "gcloud storage cp bundle/schoolbus-api.zip gs://YOUR_BUCKET_NAME/" 