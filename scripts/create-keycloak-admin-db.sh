#!/bin/bash

# Script para criar usuário admin no Keycloak via banco de dados
# ATENÇÃO: Esta é uma solução temporária. O correto é usar o port-forward ou criar via API

set -e

export KUBECONFIG=~/.kube/config

echo "🔧 Criando usuário admin no Keycloak via banco de dados"
echo ""

# Verificar se estamos conectados ao cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Não é possível acessar o cluster Kubernetes"
    exit 1
fi

# Obter pod do PostgreSQL
POSTGRES_POD=$(kubectl get pod -n innexar-platform -l app=postgres-keycloak -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POSTGRES_POD" ]; then
    echo "❌ Pod do PostgreSQL do Keycloak não encontrado"
    exit 1
fi

echo "📋 Pod PostgreSQL: $POSTGRES_POD"
echo ""

# Gerar UUID para o usuário
USER_ID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || echo "")

if [ -z "$USER_ID" ]; then
    echo "❌ Não foi possível gerar UUID. Instale uuidgen ou python3"
    exit 1
fi

echo "🔑 ID do usuário: $USER_ID"
echo ""

# Senha (vamos precisar gerar o hash bcrypt)
PASSWORD="K3ycl0@k_Adm1n_P@ss_2025!"

echo "⚠️  ATENÇÃO: Inserir usuário diretamente no banco é complexo porque:"
echo "   1. Precisa gerar hash bcrypt da senha"
echo "   2. Precisa criar registro na tabela credential"
echo "   3. Precisa associar ao realm 'master'"
echo ""
echo "💡 SOLUÇÃO RECOMENDADA:"
echo ""
echo "   Use SSH Tunnel ou port-forward com --address 0.0.0.0"
echo ""
echo "   No servidor:"
echo "   kubectl port-forward -n innexar-platform \\"
echo "     \$(kubectl get pod -n innexar-platform -l app=keycloak -o jsonpath='{.items[0].metadata.name}') \\"
echo "     9080:8080 --address 0.0.0.0"
echo ""
echo "   No navegador (do seu computador):"
echo "   http://SEU_IP_SERVIDOR:9080"
echo ""
echo "   Ou use SSH Tunnel do seu computador:"
echo "   ssh -L 9080:localhost:9080 root@SEU_IP_SERVIDOR"
echo ""
echo "   E depois: http://localhost:9080"
echo ""


