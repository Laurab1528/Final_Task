# Contributing Guide

## Branch Strategy

We follow a trunk-based development approach with short-lived feature branches:

- `main`: Production-ready code
- `feature/*`: New features or updates
- `fix/*`: Bug fixes
- `hotfix/*`: Emergency fixes for production

## Development Workflow

1. **Create a feature branch from main:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes with clear, atomic commits:**
   ```bash
   git commit -m "feat: add new endpoint for products"
   ```

3. **Push your branch and create a Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Open a Pull Request (PR) to `main`.
   - Link your PR to relevant GitHub issues using keywords like `Closes #issue_number`.

4. **Pull Request Process:**
   - Update documentation if needed.
   - Add or update tests for new features.
   - Ensure the CI pipeline passes (tests, security, linting, etc.).
   - Request review from at least one team member.
   - Address feedback and make changes as needed.
   - Squash and merge to `main` only after approval.

5. **Branch Deletion:**
   - After merging, delete the feature/fix branch to keep the repository clean.

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

- Regularly pull from `main` to keep your branch updated:
  ```bash
  git fetch origin
  git rebase origin/main
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

---

**By following this workflow, we ensure code quality, security, and a clean project history.** 