# Contributing Guide

## Branch Strategy

This repository uses a simple branch strategy with only two main branches:

- `main`: Production-ready code
- `feature`: All development work and new features are implemented here



## Development Workflow

1. **Checkout the feature branch:**
   ```bash
   git checkout feature
   ```

2. **Create a local branch for your work (optional, for organization):**
   ```bash
   git checkout -b your-local-feature
   ```

3. **Make your changes with clear, atomic commits:**
   ```bash
   git commit -m "feat: add new endpoint for products"
   ```

4. **Push your changes to the remote feature branch:**
   ```bash
   git push origin feature
   ```

5. **Create a Pull Request (PR) from `feature` to `main`:**
   - Open a Pull Request (PR) to `main`.
   - Link your PR to relevant GitHub issues using keywords like `Closes #issue_number`.

6. **Pull Request Process:**
   - Update documentation if needed.
   - Add or update tests for new features.
   - Ensure the CI pipeline passes (tests, security, linting, etc.).
   - Request review from at least one team member.
   - Address feedback and make changes as needed.
   - Squash and merge to `main` only after approval.

7. **Branch Deletion:**
   - After merging, delete any local branches you created to keep your workspace clean.

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `chore:` Maintenance
- `test:` Test updates
- `refactor:` Code refactoring

## Code Review Guidelines

- Review for security best practices (Bandit, Safety, tfsec results).
- Check for sufficient test coverage.
- Verify documentation is updated.
- Ensure CI/CD pipeline passes before approving.

## Keeping Your Branch Up to Date

- Regularly pull from `feature` to keep your local branch updated:
  ```bash
  git fetch origin
  git rebase origin/feature
  ```
- Resolve any conflicts before requesting a review.

## Agile Practices

- Use GitHub Issues and Projects to track work.
- Link PRs to issues for traceability.
- Use clear, descriptive PR titles and descriptions.

## Deployment and Kubernetes Resources

- All application deployments and Kubernetes resources are managed via Helm charts, which are installed and updated automatically by Terraform using the Helm provider.
- **Do not apply Kubernetes YAML manifests manually or use kubectl for these resources.**
- To deploy or update the application, always use:
  ```bash
  cd terraform
  terraform apply
  ```
- To change environments (dev, prod), update the values file referenced in the `helm_release` resource in Terraform.

## CI/CD Workflow Overview

- **Pull Request to `main`:**
  - The infrastructure workflow (`infrastructure-pipeline.yml`) runs a validation of Terraform changes (plan, checks).
  - The application workflow (`app-pipeline.yml`) runs tests and builds the application, but does NOT deploy.

- **Merge to `main`:**
  - The infrastructure workflow applies all Terraform changes, provisioning or updating AWS resources.
  - The application workflow builds the Docker image, pushes it to ECR, and deploys the application to EKS using Helm.

This ensures that only reviewed and approved code is deployed to production, and that all changes are validated before being applied.

---

**By following this workflow, we ensure code quality, security, and a clean project history.** 