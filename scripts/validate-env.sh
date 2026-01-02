#!/bin/bash

# Environment Variables Validation Script
# Run with: bash scripts/validate-env.sh

echo "=== Validating Environment Variables ==="
echo

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if .env file exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "❌ ERROR: .env file not found!"
    echo "   Run: cp .env.example .env"
    exit 1
fi

# Source environment variables
set -a
source "$PROJECT_ROOT/.env"
set +a

echo "✅ .env file found and loaded"
echo

# Check required variables
REQUIRED_VARS=(
    "ACME_EMAIL"
    "CLOUDFLARE_EMAIL"
    "CLOUDFLARE_API_TOKEN"
    "SMTP_USERNAME"
    "SMTP_PASSWORD"
    "SONAR_DB_PASSWORD"
    "KEYCLOAK_ADMIN_PASSWORD"
    "KEYCLOAK_DB_PASSWORD"
)

WARNING_VARS=(
    "TRAEFIK_BASIC_AUTH"
)

echo "🔍 Checking required variables..."
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ] || [[ "${!var}" == change-* ]] || [[ "${!var}" == your-* ]]; then
        echo "❌ $var: NOT SET or using default placeholder"
    else
        echo "✅ $var: SET"
    fi
done

echo
echo "⚠️  Checking optional variables..."
for var in "${WARNING_VARS[@]}"; do
    if [ -z "${!var}" ] || [[ "${!var}" == *...* ]]; then
        echo "⚠️  $var: NOT SET (will use default)"
    else
        echo "✅ $var: SET"
    fi
done

echo
echo "📧 Email Configuration:"
echo "   ACME Email: $ACME_EMAIL"
echo "   GitLab From: $GITLAB_EMAIL_FROM"

echo
echo "🔐 Security Check:"
if [[ "$ACME_EMAIL" == *"innexar.app" ]]; then
    echo "✅ ACME Email uses innexar.app domain"
else
    echo "⚠️  ACME Email does not use innexar.app domain"
fi

echo
echo "=== Validation Complete ==="
