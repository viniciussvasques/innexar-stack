# 🔐 Resumo: Configuração SSO com Keycloak

Guia rápido para configurar Single Sign-On (SSO) na Plataforma Innexar.

## 🎯 Objetivo

Permitir que usuários façam login uma única vez no Keycloak e tenham acesso automático a:
- ✅ GitLab
- ✅ SonarQube  
- ✅ Nexus Repository

## ⚡ Início Rápido

### 1. Acessar Keycloak Admin

```
URL: https://auth.innexar.app
Usuário: admin
Senha: K3ycl0@k_Adm1n_P@ss_2025!
```

### 2. Criar Realm "innexar"

1. Clique no dropdown **"master"** (canto superior esquerdo)
2. Clique em **"Create Realm"**
3. Nome: `innexar`
4. Clique em **"Create"**

### 3. Criar Usuário de Teste

1. Menu lateral: **Users** → **Create new user**
2. Preencha:
   - Username: `dev1`
   - Email: `dev1@innexar.app`
   - ✅ Email Verified: `ON`
3. Aba **Credentials** → **Set password**
   - Password: `Dev@123456`
   - ✅ Temporary: `OFF`

### 4. Criar Clients OAuth2

Para cada serviço (GitLab, SonarQube, Nexus), crie um Client:

**Menu lateral: Clients → Create client**

#### GitLab Client:
- **Client ID**: `gitlab`
- **Client authentication**: `ON`
- **Valid redirect URIs**: `https://git.innexar.app/users/auth/openid_connect/callback`
- **Anotar**: Client Secret (aba Credentials)

#### SonarQube Client:
- **Client ID**: `sonarqube`
- **Client authentication**: `ON`
- **Valid redirect URIs**: `https://sonar.innexar.app/oauth2/callback/keycloak`
- **Anotar**: Client Secret

#### Nexus Client:
- **Client ID**: `nexus`
- **Client authentication**: `ON`
- **Valid redirect URIs**: `https://nexus.innexar.app/oauth2/callback`
- **Anotar**: Client Secret

### 5. Configurar Cada Serviço

#### GitLab
1. Acesse: https://git.innexar.app
2. Login como root
3. Edite `/etc/gitlab/gitlab.rb`:
```ruby
gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
gitlab_rails['omniauth_providers'] = [
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
        secret: 'SEU_CLIENT_SECRET_GITLAB',
        redirect_uri: 'https://git.innexar.app/users/auth/openid_connect/callback'
      }
    }
  }
]
```
4. Execute:
```bash
docker compose exec gitlab gitlab-ctl reconfigure
docker compose restart gitlab
```

#### SonarQube
⚠️ **Nota**: SonarQube Community Edition tem suporte limitado a OAuth2.
- Use SonarQube Developer Edition para suporte completo
- Ou configure manualmente via propriedades (ver guia completo)

#### Nexus
1. Acesse: https://nexus.innexar.app
2. Login como admin
3. **Settings** → **Security** → **Realms**
   - Ative: **OIDC Realm**
4. **Settings** → **Security** → **OIDC Connection**
   - Name: `Keycloak`
   - Discovery URI: `https://auth.innexar.app/realms/innexar/.well-known/openid-configuration`
   - Client ID: `nexus`
   - Client Secret: `SEU_CLIENT_SECRET_NEXUS`
   - Email claim: `email`
   - Groups claim: `groups`
5. Test Connection → Save

## 📋 Checklist

- [ ] Keycloak acessível em https://auth.innexar.app
- [ ] Realm "innexar" criado
- [ ] Usuário de teste criado
- [ ] Client "gitlab" criado e Client Secret anotado
- [ ] Client "sonarqube" criado e Client Secret anotado
- [ ] Client "nexus" criado e Client Secret anotado
- [ ] GitLab configurado com OAuth2
- [ ] SonarQube configurado (se aplicável)
- [ ] Nexus configurado com OIDC
- [ ] Teste de login SSO realizado

## 🔧 Informações Úteis

### URLs Importantes

```bash
# Endpoint Discovery
https://auth.innexar.app/realms/innexar/.well-known/openid-configuration

# Issuer
https://auth.innexar.app/realms/innexar
```

### Script Auxiliar

```bash
bash scripts/get-keycloak-info.sh
```

Este script exibe todas as URLs e informações necessárias para configuração.

## 📚 Documentação Completa

Para instruções detalhadas passo-a-passo, consulte:
- **[KEYCLOAK_SSO_SETUP.md](./KEYCLOAK_SSO_SETUP.md)**: Guia completo e detalhado

## ⚠️ Notas Importantes

1. **Client Secrets**: Mantenha em local seguro (não commite no Git)
2. **HTTPS**: Todos os serviços devem usar HTTPS
3. **Redirect URIs**: Devem ser exatamente iguais entre Keycloak e o serviço
4. **Modo Dev**: Keycloak está em modo `start-dev` - para produção, considere usar `start`

## 🆘 Troubleshooting

**Erro de Redirect URI**: Verifique se as URIs estão idênticas em ambos os lados

**Client Secret inválido**: Verifique se copiou corretamente (sem espaços extras)

**Usuário não sincronizado**: Configure mappers no Keycloak (ver guia completo)

---

**Última atualização**: Janeiro 2026
