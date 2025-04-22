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