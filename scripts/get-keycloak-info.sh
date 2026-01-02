#!/bin/bash

# Script para obter informações do Keycloak necessárias para configuração SSO
# Run with: bash scripts/get-keycloak-info.sh

set -e

echo "🔐 Keycloak SSO Configuration Info"
echo "===================================="
echo

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "❌ ERROR: .env file not found!"
    exit 1
fi

source "$PROJECT_ROOT/.env"

KEYCLOAK_URL="https://auth.innexar.app"
REALM="innexar"

echo "📋 Informações de Configuração do Keycloak"
echo
echo "Realm: $REALM"
echo "Keycloak URL: $KEYCLOAK_URL"
echo
echo "🔗 URLs de Endpoints:"
echo "----------------------------------------"
echo "Issuer: $KEYCLOAK_URL/realms/$REALM"
echo "Authorization Endpoint: $KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/auth"
echo "Token Endpoint: $KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token"
echo "Userinfo Endpoint: $KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/userinfo"
echo "JWK Set: $KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/certs"
echo "Discovery: $KEYCLOAK_URL/realms/$REALM/.well-known/openid-configuration"
echo
echo "📝 Client IDs Necessários:"
echo "----------------------------------------"
echo "GitLab Client ID: gitlab"
echo "SonarQube Client ID: sonarqube"
echo "Nexus Client ID: nexus"
echo
echo "🔑 Para obter Client Secrets:"
echo "----------------------------------------"
echo "1. Acesse: $KEYCLOAK_URL"
echo "2. Faça login no Admin Console"
echo "3. Selecione o realm: $REALM"
echo "4. Vá em: Clients → [client-name] → Credentials"
echo "5. Copie o Client Secret"
echo
echo "📚 Documentação Completa:"
echo "----------------------------------------"
echo "Consulte: KEYCLOAK_SSO_SETUP.md para instruções detalhadas"
echo
echo "✅ Para testar conectividade:"
echo "----------------------------------------"
echo "curl -k $KEYCLOAK_URL/realms/$REALM/.well-known/openid-configuration"
echo

