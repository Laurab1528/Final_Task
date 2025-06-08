# Final Cloud & DevOps Project

This project implements a complete CI/CD solution to deploy a Python (FastAPI) application on AWS EKS.

## Project Structure

```
.
├── app/                    # FastAPI Application
│   ├── main.py            # Main code
│   ├── requirements.txt    # Dependencies
│   ├── Dockerfile         # Container configuration
│   └── test_main.py       # Unit tests
│
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # Main configuration
│   └── modules/          # Terraform modules
│       ├── vpc/          # VPC configuration
│       └── eks/          # EKS configuration
│
├── kubernetes/           # Kubernetes manifests
│   ├── deployment.yaml  # Deployment configuration
│   └── service.yaml    # Service configuration
│
└── .github/workflows/   # CI/CD Pipelines
    ├── app-pipeline.yml        # Application pipeline
    └── infrastructure-pipeline.yml  # Infrastructure pipeline
```

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed
3. kubectl installed
4. Docker installed
5. Python 3.10 or higher

## Configuration

### 1. AWS Environment Variables

Configure the following variables in GitHub Secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

### 2. Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Local Application

```bash
cd app
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 4. Local Docker

```bash
cd app
docker build -t fastapi-app .
docker run -p 80:80 fastapi-app
```

## Pipelines

### Application Pipeline
- Runs tests
- Builds Docker image
- Publishes to ECR
- Deploys to EKS

### Infrastructure Pipeline
- Validates Terraform configuration
- Plans changes
- Applies infrastructure changes

## Endpoints

- `/health`: Health check
- `/api/products`: Example endpoint returning JSON

## Monitoring

To check deployment status:

```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

## Security

- Minimal required IAM roles and policies
- Private subnets for EKS nodes
- Access through ALB in public subnet

## Contributing

1. Create a feature/ branch
2. Make changes
3. Create Pull Request
4. Wait for pipeline validation
5. Merge to main

## Support

For issues or questions, please create an issue in the repository. 