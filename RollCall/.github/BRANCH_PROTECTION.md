# Branch Protection Rules

This document outlines the branch protection rules that should be configured in GitHub for the RollCall repository.

## Protected Branches

### `main` Branch

The `main` branch is the production branch and requires the strictest protection.

#### Protection Rules

1. **Require pull request reviews before merging**
   - [x] Required approving reviews: **1**
   - [x] Dismiss stale pull request approvals when new commits are pushed
   - [x] Require review from CODEOWNERS
   - [x] Restrict who can dismiss pull request reviews

2. **Require status checks to pass before merging**
   - [x] Require branches to be up to date before merging
   - Required status checks:
     - `CI/CD Pipeline / Lint & Format Check`
     - `CI/CD Pipeline / Build & Test`
     - `CI/CD Pipeline / Security Scan`
     - `CI/CD Pipeline / Collect CI Metrics`

3. **Require conversation resolution before merging**
   - [x] All conversations must be resolved

4. **Require signed commits**
   - [x] Require signed commits (recommended for production)

5. **Include administrators**
   - [x] Include administrators in these restrictions

6. **Restrict who can push to matching branches**
   - [x] Restrict pushes that create matching branches
   - Allowed users/teams: `[maintainers only]`

7. **Rules for force pushes and deletions**
   - [x] Do not allow force pushes
   - [x] Do not allow deletions

### `develop` Branch

The `develop` branch is the integration branch for new features.

#### Protection Rules

1. **Require pull request reviews before merging**
   - [x] Required approving reviews: **1**
   - [ ] Dismiss stale pull request approvals when new commits are pushed
   - [ ] Require review from CODEOWNERS

2. **Require status checks to pass before merging**
   - [x] Require branches to be up to date before merging
   - Required status checks:
     - `CI/CD Pipeline / Lint & Format Check`
     - `CI/CD Pipeline / Build & Test`

3. **Require conversation resolution before merging**
   - [x] All conversations must be resolved

4. **Include administrators**
   - [ ] Include administrators in these restrictions

5. **Rules for force pushes and deletions**
   - [x] Do not allow force pushes
   - [x] Do not allow deletions

## Setting Up Branch Protection

### Via GitHub Web UI

1. Navigate to **Settings** → **Branches** in your repository
2. Click **Add rule** under "Branch protection rules"
3. Enter the branch name pattern (e.g., `main` or `develop`)
4. Configure the rules as specified above
5. Click **Create** or **Save changes**

### Via GitHub CLI

```bash
# Install GitHub CLI if not already installed
brew install gh

# Authenticate with GitHub
gh auth login

# Set branch protection for main
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --header "Accept: application/vnd.github+json" \
  --field required_status_checks='{"strict":true,"contexts":["CI/CD Pipeline / Lint & Format Check","CI/CD Pipeline / Build & Test","CI/CD Pipeline / Security Scan"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false

# Set branch protection for develop
gh api repos/OWNER/REPO/branches/develop/protection \
  --method PUT \
  --header "Accept: application/vnd.github+json" \
  --field required_status_checks='{"strict":true,"contexts":["CI/CD Pipeline / Lint & Format Check","CI/CD Pipeline / Build & Test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## Auto-merge Configuration

For approved PRs that meet all requirements:

1. **Enable auto-merge** in repository settings
2. Configure merge methods:
   - [x] Allow squash merging (recommended for feature branches)
   - [ ] Allow merge commits
   - [ ] Allow rebase merging

3. Default commit message:
   - Squash merge: Use PR title and description
   - Delete branch after merge: **Enabled**

## CODEOWNERS File

Create a `.github/CODEOWNERS` file to automatically request reviews:

```
# Global owners
* @maintainer-username

# iOS specific
*.swift @ios-team
*.xcodeproj @ios-team
RollCall/ @ios-team

# CI/CD
.github/ @devops-team
scripts/ @devops-team

# Documentation
*.md @documentation-team
```

## Bypass Rules (Emergency Only)

In case of critical production issues:

1. Repository admins can temporarily disable branch protection
2. Apply hotfix directly to `main`
3. Re-enable protection immediately after
4. Create backport PR to `develop`
5. Document the emergency bypass in incident report

## Monitoring and Compliance

### Weekly Checks
- Review PR merge times and bottlenecks
- Check for stale PRs waiting for review
- Verify all required checks are passing

### Monthly Audit
- Review branch protection effectiveness
- Check for any direct commits to protected branches
- Update required status checks as needed
- Review CODEOWNERS assignments

## Enforcement Timeline

| Phase | Date | Requirements |
|-------|------|--------------|
| MVP | Now | Basic protection, 1 review, CI checks |
| Beta | TBD | Add security scanning, coverage thresholds |
| Production | TBD | Signed commits, 2 reviews for main |

## Exceptions

No exceptions to branch protection rules except:
- Security hotfixes (with post-incident review)
- CI/CD configuration updates (with admin approval)

## Support

For questions about branch protection:
- Check this documentation first
- Ask in #dev-help Slack channel
- Contact repository maintainers

---

Last Updated: 2024-12-XX
Next Review: 2025-01-XX