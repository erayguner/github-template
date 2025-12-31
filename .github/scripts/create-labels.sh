#!/bin/bash
# Script to create missing Dependabot labels
# Run this script after authenticating with: gh auth login

set -e

echo "Creating missing Dependabot labels..."

# Create 'dependencies' label (orange color for dependency updates)
gh label create "dependencies" \
  --description "Pull requests that update a dependency file" \
  --color "0366d6" \
  --force 2>/dev/null && echo "✓ Created 'dependencies' label" || echo "  'dependencies' label already exists"

# Create 'github-actions' label (purple color for GitHub Actions)
gh label create "github-actions" \
  --description "Pull requests that update GitHub Actions code" \
  --color "5319e7" \
  --force 2>/dev/null && echo "✓ Created 'github-actions' label" || echo "  'github-actions' label already exists"

# Create 'ci-cd' label (blue color for CI/CD)
gh label create "ci-cd" \
  --description "Continuous integration and deployment" \
  --color "1d76db" \
  --force 2>/dev/null && echo "✓ Created 'ci-cd' label" || echo "  'ci-cd' label already exists"

# Create 'security' label (red color for security)
gh label create "security" \
  --description "Security-related updates and fixes" \
  --color "d73a4a" \
  --force 2>/dev/null && echo "✓ Created 'security' label" || echo "  'security' label already exists"

# Create additional labels used in dependabot.yml
gh label create "npm" \
  --description "JavaScript dependencies" \
  --color "cb3837" \
  --force 2>/dev/null && echo "✓ Created 'npm' label" || echo "  'npm' label already exists"

gh label create "python" \
  --description "Python dependencies" \
  --color "3776ab" \
  --force 2>/dev/null && echo "✓ Created 'python' label" || echo "  'python' label already exists"

gh label create "terraform" \
  --description "Terraform dependencies" \
  --color "7B42BC" \
  --force 2>/dev/null && echo "✓ Created 'terraform' label" || echo "  'terraform' label already exists"

gh label create "infrastructure" \
  --description "Infrastructure as Code" \
  --color "006b75" \
  --force 2>/dev/null && echo "✓ Created 'infrastructure' label" || echo "  'infrastructure' label already exists"

gh label create "docker" \
  --description "Docker dependencies" \
  --color "2496ed" \
  --force 2>/dev/null && echo "✓ Created 'docker' label" || echo "  'docker' label already exists"

echo ""
echo "✓ All labels created successfully!"
echo "Run 'gh label list' to verify the labels"
