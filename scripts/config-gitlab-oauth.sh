#!/bin/bash

# Script para configurar OAuth do Keycloak no GitLab
# Uso: bash scripts/config-gitlab-oauth.sh <KEYCLOAK_CLIENT_SECRET>

set -e

if [ -z "$1" ]; then
    echo "❌ Erro: Client Secret do Keycloak é necessário"
    echo "Uso: bash scripts/config-gitlab-oauth.sh <KEYCLOAK_CLIENT_SECRET>"
    exit 1
fi

CLIENT_SECRET="$1"
KEYCLOAK_URL="https://auth.innexar.app/realms/innexar"
GITLAB_URL="https://git.innexar.app"

echo "🔧 Configurando GitLab OAuth com Keycloak..."
echo ""

# Obter nome do pod GitLab
GITLAB_POD=$(kubectl get pod -n innexar-platform -l app=gitlab -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$GITLAB_POD" ]; then
    echo "❌ Pod do GitLab não encontrado"
    exit 1
fi

echo "📋 Pod GitLab: ${GITLAB_POD}"
echo ""
echo "⚠️  ATENÇÃO: Esta configuração requer acesso ao Rails console do GitLab"
echo ""
echo "Para configurar manualmente:"
echo ""
echo "1. Acesse o pod:"
echo "   kubectl exec -it -n innexar-platform ${GITLAB_POD} -- bash"
echo ""
echo "2. Acesse Rails console:"
echo "   gitlab-rails console"
echo ""
echo "3. Execute o seguinte código Ruby:"
echo ""
cat <<'RUBY_CODE'
app_settings = Gitlab::CurrentSettings.current_application_settings
app_settings.update!(
  omniauth_enabled: true,
  omniauth_allow_single_sign_on: ['openid_connect'],
  omniauth_block_auto_created_users: false,
  omniauth_providers: [
    {
      name: 'openid_connect',
      label: 'Keycloak',
      args: {
        name: 'openid_connect',
        scope: ['openid', 'profile', 'email'],
        response_type: 'code',
        issuer: 'https://auth.innexar.app/realms/innexar',
        discovery: true,
        client_auth_method: 'query',
        uid_field: 'preferred_username',
        client_options: {
          identifier: 'gitlab',
          secret: 'SEU_CLIENT_SECRET_AQUI',
          redirect_uri: 'https://git.innexar.app/users/auth/openid_connect/callback'
        }
      }
    }
  ]
)
RUBY_CODE

echo ""
echo "⚠️  Substitua 'SEU_CLIENT_SECRET_AQUI' pelo secret real do Keycloak"
echo ""
echo "4. Após configurar, reinicie o GitLab:"
echo "   kubectl rollout restart deployment gitlab -n innexar-platform"
echo ""

