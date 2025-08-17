#!/bin/bash

# RollCall Repository Setup Script
# This script helps set up the repository for GitHub with proper CI/CD

set -e

echo "🍣 RollCall Repository Setup"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI not installed. Install with: brew install gh"
else
    print_status "GitHub CLI installed"
fi

if ! command -v swiftlint &> /dev/null; then
    print_warning "SwiftLint not installed. Install with: brew install swiftlint"
else
    print_status "SwiftLint installed"
fi

if ! command -v swiftformat &> /dev/null; then
    print_warning "SwiftFormat not installed. Install with: brew install swiftformat"
else
    print_status "SwiftFormat installed"
fi

echo ""

# Get repository information
read -p "Enter GitHub username/organization: " GITHUB_OWNER
read -p "Enter repository name (default: rollcall): " REPO_NAME
REPO_NAME=${REPO_NAME:-rollcall}

echo ""
echo "Setting up repository: ${GITHUB_OWNER}/${REPO_NAME}"
echo ""

# Initialize git if needed
if [ ! -d .git ]; then
    print_status "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: RollCall iOS app"
else
    print_status "Git repository already initialized"
fi

# Set up GitHub remote
if git remote | grep -q origin; then
    print_status "Remote 'origin' already exists"
else
    echo "Adding GitHub remote..."
    git remote add origin "https://github.com/${GITHUB_OWNER}/${REPO_NAME}.git"
    print_status "Remote added"
fi

# Create GitHub repository using gh CLI
if command -v gh &> /dev/null; then
    echo ""
    read -p "Create repository on GitHub? (y/n): " CREATE_REPO
    if [ "$CREATE_REPO" = "y" ]; then
        echo "Creating repository on GitHub..."
        
        gh repo create "${GITHUB_OWNER}/${REPO_NAME}" \
            --public \
            --description "🍣 Social sushi logging app for iOS" \
            --homepage "https://rollcallapp.com" \
            --add-readme \
            --clone=false \
            --license MIT || print_warning "Repository may already exist"
        
        print_status "Repository created/verified on GitHub"
    fi
fi

# Push to GitHub
echo ""
read -p "Push to GitHub? (y/n): " PUSH_TO_GITHUB
if [ "$PUSH_TO_GITHUB" = "y" ]; then
    echo "Pushing to GitHub..."
    
    # Create develop branch
    git checkout -b develop 2>/dev/null || git checkout develop
    git push -u origin develop
    
    # Push main/master branch
    git checkout master 2>/dev/null || git checkout main
    if [ "$(git branch --show-current)" = "master" ]; then
        # Rename master to main
        git branch -m master main
    fi
    git push -u origin main
    
    print_status "Code pushed to GitHub"
fi

# Set up branch protection
if command -v gh &> /dev/null; then
    echo ""
    read -p "Set up branch protection rules? (y/n): " SETUP_PROTECTION
    if [ "$SETUP_PROTECTION" = "y" ]; then
        echo "Setting up branch protection for 'main'..."
        
        gh api "repos/${GITHUB_OWNER}/${REPO_NAME}/branches/main/protection" \
            --method PUT \
            --field required_status_checks='{"strict":true,"contexts":["CI/CD Pipeline / Lint & Format Check","CI/CD Pipeline / Build & Test"]}' \
            --field enforce_admins=true \
            --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
            --field allow_force_pushes=false \
            --field allow_deletions=false \
            2>/dev/null || print_warning "Branch protection may already be configured"
        
        print_status "Branch protection configured"
    fi
fi

# Set up secrets for GitHub Actions
echo ""
echo "GitHub Actions Secrets Setup"
echo "----------------------------"
echo "You'll need to manually add these secrets in GitHub:"
echo "1. Go to: https://github.com/${GITHUB_OWNER}/${REPO_NAME}/settings/secrets/actions"
echo "2. Add the following secrets (if applicable):"
echo "   - APP_STORE_CONNECT_API_KEY_ID"
echo "   - APP_STORE_CONNECT_API_ISSUER_ID"
echo "   - APP_STORE_CONNECT_API_KEY"
echo "   - SENTRY_AUTH_TOKEN"
echo "   - SENTRY_ORG"
echo "   - SENTRY_PROJECT"
echo ""

# Enable GitHub Actions
echo "GitHub Actions Setup"
echo "-------------------"
echo "1. Go to: https://github.com/${GITHUB_OWNER}/${REPO_NAME}/actions"
echo "2. Enable Actions if not already enabled"
echo "3. The CI/CD workflow will run automatically on push/PR"
echo ""

# Final steps
echo "Next Steps"
echo "----------"
echo "1. Review and update README.md with your specific details"
echo "2. Update badge URLs in README.md"
echo "3. Configure Codecov integration at https://codecov.io"
echo "4. Set up TestFlight deployment credentials"
echo "5. Configure Sentry for crash reporting"
echo "6. Create a 'develop' branch for feature integration"
echo ""

print_status "Repository setup complete! 🎉"
echo ""
echo "Repository URL: https://github.com/${GITHUB_OWNER}/${REPO_NAME}"
echo "Clone command: git clone https://github.com/${GITHUB_OWNER}/${REPO_NAME}.git"
echo ""
echo "Happy coding! 🍣"