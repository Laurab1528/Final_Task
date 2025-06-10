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

## Security and Quality Practices

- **Secrets Management:** Application secrets (API_KEY, etc.) are never stored in the repository or passed through the pipeline. They are managed in AWS Secrets Manager and accessed securely from the application using IRSA (IAM Roles for Service Accounts).
- **Infrastructure Security:** All Terraform code is scanned for security issues using [tfsec](https://aquasecurity.github.io/tfsec/) in the CI pipeline.
- **Python Code Security:** The application code is scanned with [Bandit](https://bandit.readthedocs.io/en/latest/) and dependencies are checked with [Safety](https://pyup.io/safety/) on every Pull Request and push to main.
- **Automated CI/CD:** All pipelines are triggered automatically on Pull Requests and pushes to main, ensuring that only validated and reviewed code reaches production.
- **Branching Strategy:** We use trunk-based development with short-lived feature branches and Pull Requests for all changes (see [CONTRIBUTING.md](docs/CONTRIBUTING.md)).
- **Agile Practices:** Issues and GitHub Projects are used to track tasks, bugs, and features. Pull Requests are linked to issues for traceability.
- **Documentation:** This repository includes setup instructions, architecture diagrams, and pipeline descriptions. See below for details.

## How to Contribute

1. Create a feature or fix branch from `main`.
2. Make your changes and commit using [Conventional Commits](https://www.conventionalcommits.org/).
3. Push your branch and open a Pull Request.
4. Ensure your PR passes all CI checks (tests, security, linting, etc.).
5. Link your PR to any relevant issues.
6. Wait for review and approval before merging.

For more details, see [CONTRIBUTING.md](docs/CONTRIBUTING.md).

## Support

For issues or questions, please create an issue in the repository.

## Helm Integration with Terraform

- The deployment of the FastAPI application and all Kubernetes resources is now fully managed by Terraform using the [Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs).
- The `helm_release` resource in `terraform/main.tf` automatically installs and updates the Helm chart (`helm/fastapi-app`) in your EKS cluster.
- You no longer need to apply Kubernetes YAML manifests manually or use `kubectl` for these resources.
- To deploy or update the application, simply run:
  ```bash
  cd terraform
  terraform apply
  ```
- You can switch environments (dev, prod) by changing the values file referenced in the `helm_release` resource. 