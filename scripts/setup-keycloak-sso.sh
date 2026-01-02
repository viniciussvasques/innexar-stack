#!/bin/bash

# Script de Configuração Inicial do Keycloak SSO
# Execute: bash scripts/setup-keycloak-sso.sh

set -e

echo "🔐 Configurando Keycloak SSO para Plataforma Innexar"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

KEYCLOAK_URL="https://auth.innexar.app"
REALM_NAME="innexar"

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não encontrado. Instale o kubectl primeiro."
    exit 1
fi

# Verificar acesso ao cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Não é possível acessar o cluster Kubernetes"
    exit 1
fi

echo "📋 Informações necessárias:"
echo ""
echo "1. Acesse o Keycloak Admin Console:"
echo "   URL: ${GREEN}${KEYCLOAK_URL}${NC}"
echo ""
echo "2. Login inicial:"
echo "   Username: ${GREEN}admin${NC}"
echo "   Password: ${YELLOW}(verificar no secrets)${NC}"
echo ""

# Tentar obter senha do secret
PASSWORD=$(kubectl get secret keycloak-secret -n innexar-platform -o jsonpath='{.data.KC_ADMIN_PASSWORD}' 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ -n "$PASSWORD" ]; then
    echo "   Password: ${GREEN}${PASSWORD}${NC}"
else
    echo "   ${YELLOW}Password não encontrado. Verifique no secret keycloak-secret${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 PRÓXIMOS PASSOS MANUAIS:"
echo ""
echo "1. ✅ Criar Realm '${REALM_NAME}' no Keycloak"
echo "2. ✅ Criar usuário administrador"
echo "3. ✅ Criar Clients (gitlab, sonarqube, nexus, grafana)"
echo "4. ✅ Configurar GitLab OAuth"
echo "5. ✅ Configurar SonarQube OAuth"
echo "6. ✅ Configurar Nexus OIDC"
echo ""
echo "📄 Consulte o guia completo: ${GREEN}INTEGRACAO_COMPLETA.md${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 URLs dos Serviços:"
echo "   Keycloak:  ${GREEN}${KEYCLOAK_URL}${NC}"
echo "   GitLab:    ${GREEN}https://git.innexar.app${NC}"
echo "   SonarQube: ${GREEN}https://sonar.innexar.app${NC}"
echo "   Nexus:     ${GREEN}https://nexus.innexar.app${NC}"
echo "   Grafana:   ${GREEN}https://grafana.innexar.app${NC}"
echo ""
