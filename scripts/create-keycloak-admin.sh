#!/bin/bash

# Script para criar usuário admin no Keycloak
# Este script cria um port-forward e instrui o usuário a acessar localhost

set -e

echo "🔐 Criando usuário admin no Keycloak"
echo ""

export KUBECONFIG=~/.kube/config

# Obter pod do Keycloak
KEYCLOAK_POD=$(kubectl get pod -n innexar-platform -l app=keycloak -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$KEYCLOAK_POD" ]; then
    echo "❌ Pod do Keycloak não encontrado"
    exit 1
fi

echo "📋 Pod encontrado: $KEYCLOAK_POD"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 INSTRUÇÕES:"
echo ""
echo "1. Execute o comando abaixo em UM TERMINAL SEPARADO (deixe rodando):"
echo ""
echo "   ${GREEN}kubectl port-forward -n innexar-platform $KEYCLOAK_POD 8080:8080${NC}"
echo ""
echo "2. Em outro terminal OU navegador, acesse:"
echo ""
echo "   ${GREEN}http://localhost:8080${NC}"
echo ""
echo "3. O Keycloak mostrará a tela de criação de admin"
echo ""
echo "4. Preencha:"
echo "   - Username: ${GREEN}admin${NC}"
echo "   - Password: ${GREEN}K3ycl0@k_Adm1n_P@ss_2025!${NC}"
echo "   - Password confirmation: ${GREEN}K3ycl0@k_Adm1n_P@ss_2025!${NC}"
echo ""
echo "5. Após criar, você poderá acessar normalmente:"
echo "   ${GREEN}https://auth.innexar.app${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 DICA: Mantenha o port-forward rodando até criar o usuário admin"
echo ""

