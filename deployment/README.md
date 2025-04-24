# SchoolBus API Gateway - Scripts de Deployment

Acest director conține scripturi și configurații pentru deployarea API Gateway-ului SchoolBus folosind Terraform.

## Structura directorului

```
deployment/
├── README.md                 # Acest fișier
├── setup.sh                  # Script pentru configurarea inițială
├── update-targets.sh         # Script pentru actualizarea adreselor microserviciilor
├── verify-deployment.sh      # Script pentru verificarea deployment-ului
└── terraform/                # Configurații Terraform
    ├── main.tf               # Configurația principală Terraform
    ├── variables.tf          # Definiții de variabile Terraform
    ├── outputs.tf            # Outputuri Terraform
    └── terraform.tfvars.example  # Exemplu de valori pentru variabile
```

## Scripturi disponibile

### 1. setup.sh

Script pentru configurarea inițială a mediului:

- Generează bundle-ul API Proxy
- Creează un bucket GCS pentru stocarea stării Terraform și a bundle-ului
- Actualizează fișierele Terraform pentru a referenția corect bucket-ul

```bash
# Făi scriptul executabil
chmod +x setup.sh

# Rulează scriptul
./setup.sh
```

### 2. update-targets.sh

Script pentru actualizarea adreselor microserviciilor în fișierele target:

- Actualizează adresele microserviciilor în fișierele XML target
- Creează backup pentru fișierele originale
- Oferă instrucțiuni pentru regenerarea bundle-ului

```bash
# Făi scriptul executabil
chmod +x update-targets.sh

# Rulează scriptul
./update-targets.sh
```

### 3. verify-deployment.sh

Script pentru verificarea și testarea deployment-ului:

- Verifică existența organizației și mediului Apigee
- Listează deployment-urile existente
- Verifică hostname-urile configurate
- Oferă opțiunea de a testa endpoint-urile

```bash
# Făi scriptul executabil
chmod +x verify-deployment.sh

# Rulează scriptul
./verify-deployment.sh
```

## Pași pentru deployment complet

1. Configurare mediu:
   ```bash
   ./setup.sh
   ```

2. Actualizare adrese microservicii:
   ```bash
   ./update-targets.sh
   ```

3. Deployment cu Terraform:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. Verificare deployment:
   ```bash
   ./verify-deployment.sh
   ```

## Notă importantă

Înainte de a rula scripturile, asigură-te că ai instalat și configurat:
- Google Cloud SDK (gcloud)
- Terraform CLI
- Utilitare standard (zip, sed, etc.)

Pentru mai multe detalii despre configurarea Apigee API Gateway, consultă ghidul detaliat din README-ul principal al repository-ului. 