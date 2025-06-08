# Contributing Guide

## Branch Strategy

We follow a trunk-based development approach with short-lived feature branches:

- `main`: Production-ready code
- `feature/*`: New features or updates
- `fix/*`: Bug fixes
- `hotfix/*`: Emergency fixes for production

## Development Workflow

1. Create a feature branch from main:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes with clear, atomic commits:
   ```bash
   git commit -m "feat: add new endpoint for products"
   ```

3. Push your branch and create a Pull Request:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Link your PR to relevant GitHub issues

## Commit Message Format

We follow conventional commits:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `chore:` Maintenance
- `test:` Test updates
- `refactor:` Code refactoring

## Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure CI pipeline passes
4. Get code review from at least one team member
5. Squash and merge to main

## Code Review Guidelines

- Review for security best practices
- Check for test coverage
- Verify documentation is updated
- Ensure CI/CD pipeline passes 