# Guia de Integração Completa - Plataforma Innexar

## 📋 Visão Geral

Este guia documenta a configuração completa de SSO (Single Sign-On) integrando todos os serviços através do Keycloak.

## 🎯 Objetivo

Configurar um único ponto de autenticação (Keycloak) para todos os serviços:
- ✅ GitLab
- ✅ SonarQube  
- ✅ Nexus Repository
- ✅ Grafana (opcional)

## 🔐 Passo 1: Configuração Inicial do Keycloak

### 1.1 Acessar Keycloak Admin Console

1. Acesse: `https://auth.innexar.app`
2. Clique em **"Administration Console"**
3. Login com credenciais:
   - **Username**: `admin`
   - **Password**: Verificar no secrets (`KEYCLOAK_ADMIN_PASSWORD`)

### 1.2 Criar Realm "innexar"

1. No canto superior esquerdo, clique no dropdown (atualmente "master")
2. Clique em **"Create Realm"**
3. **Realm name**: `innexar`
4. Clique em **"Create"**

### 1.3 Configurar Realm Settings

1. Vá em **Realm Settings** → **General**
2. Configure:
   - **Display name**: `Innexar Platform`
   - **User-managed access**: OFF
   - **Endpoints**: Copie o **OpenID Endpoint Configuration** URL

3. Vá em **Realm Settings** → **Login**
   - **User registration**: ON (opcional)
   - **Forgot password**: ON
   - **Remember me**: ON

4. Vá em **Realm Settings** → **Email**
   - Configure SMTP (se necessário para recuperação de senha)

## 👥 Passo 2: Criar Usuários no Keycloak

### 2.1 Criar Usuário Administrador

1. Vá em **Users** → **Add user**
2. Configure:
   - **Username**: `admin` (ou seu usuário preferido)
   - **Email**: seu-email@innexar.app
   - **Email verified**: ON
   - **Enabled**: ON
3. Clique em **"Create"**
4. Vá na aba **Credentials**
5. Defina uma senha (desmarque "Temporary")
6. Clique em **"Set Password"**

### 2.2 Criar Grupos (Opcional)

1. Vá em **Groups** → **New**
2. Crie grupos como:
   - `developers`
   - `admins`
   - `users`

## 🔑 Passo 3: Configurar Clients no Keycloak

### 3.1 Client: GitLab

1. Vá em **Clients** → **Create**
2. Configure:
   - **Client ID**: `gitlab`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**: `https://git.innexar.app/users/auth/openid_connect/callback`
   - **Base URL**: `https://git.innexar.app`
   - **Web Origins**: `https://git.innexar.app`
3. Clique em **"Save"**
4. Vá na aba **Credentials**
5. **Copie o "Secret"** - você precisará disso para configurar o GitLab

### 3.2 Client: SonarQube

1. Vá em **Clients** → **Create**
2. Configure:
   - **Client ID**: `sonarqube`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**: `https://sonar.innexar.app/oauth2/callback/keycloak`
   - **Base URL**: `https://sonar.innexar.app`
   - **Web Origins**: `https://sonar.innexar.app`
3. Clique em **"Save"**
4. Vá na aba **Credentials**
5. **Copie o "Secret"**

### 3.3 Client: Nexus

1. Vá em **Clients** → **Create**
2. Configure:
   - **Client ID**: `nexus`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**: `https://nexus.innexar.app/*`
   - **Base URL**: `https://nexus.innexar.app`
   - **Web Origins**: `https://nexus.innexar.app`
3. Clique em **"Save"**
4. Vá na aba **Credentials**
5. **Copie o "Secret"**

### 3.4 Client: Grafana (Opcional)

1. Vá em **Clients** → **Create**
2. Configure:
   - **Client ID**: `grafana`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**: `https://grafana.innexar.app/login/generic_oauth`
   - **Base URL**: `https://grafana.innexar.app`
   - **Web Origins**: `https://grafana.innexar.app`
3. Clique em **"Save"**
4. Vá na aba **Credentials**
5. **Copie o "Secret"**

## 🔧 Passo 4: Configurar GitLab

### 4.1 Atualizar GitLab Omnibus Config

O GitLab já está configurado via ConfigMap. Precisamos atualizar com as configurações OAuth do Keycloak.

### 4.2 Configuração via Rails Console (Temporária - até criar script)

```ruby
# Acessar pod do GitLab
kubectl exec -it -n innexar-platform $(kubectl get pod -n innexar-platform -l app=gitlab -o jsonpath='{.items[0].metadata.name}') -- bash

# Dentro do pod, acessar Rails console
gitlab-rails console

# Configurar OAuth
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

exit
```

### 4.3 Reiniciar GitLab

```bash
kubectl rollout restart deployment gitlab -n innexar-platform
```

## 🔧 Passo 5: Configurar SonarQube

### 5.1 Acessar SonarQube

1. Acesse: `https://sonar.innexar.app`
2. Login inicial: `admin` / `admin` (será solicitado mudança de senha)

### 5.2 Configurar OAuth

1. Vá em **Administration** → **Configuration** → **General** → **Authentication**
2. Configure:
   - **Enabled**: ON
   - **Provider**: `OpenID Connect`
   - **Is enabled**: ON
   - **Client ID**: `sonarqube`
   - **Client Secret**: (secret do Keycloak)
   - **Issuer URI**: `https://auth.innexar.app/realms/innexar`
   - **Provider name**: `Keycloak`
   - **Allow users to sign-up**: ON (se desejar)
   - **Groups claim**: `groups`
   - **Email claim**: `email`
3. Clique em **Save**

## 🔧 Passo 6: Configurar Nexus

### 6.1 Acessar Nexus

1. Acesse: `https://nexus.innexar.app`
2. Login inicial: `admin` / (verificar senha padrão no primeiro acesso)

### 6.2 Configurar OIDC

1. Vá em **Settings** (ícone de engrenagem) → **Security** → **Realms**
2. Ative: **OIDC Realm** (arraste da esquerda para direita)
3. Clique em **Save**

4. Vá em **Settings** → **Security** → **OIDC Connection**
5. Configure:
   - **Name**: `Keycloak`
   - **Discovery URI**: `https://auth.innexar.app/realms/innexar/.well-known/openid-configuration`
   - **Client ID**: `nexus`
   - **Client Secret**: (secret do Keycloak)
   - **Email claim**: `email`
   - **Groups claim**: `groups`
   - **Username claim**: `preferred_username`
6. Clique em **Test Connection**
7. Se funcionar, clique em **Save**

## 📊 Passo 7: Configurar Grafana (Opcional)

### 7.1 Atualizar ConfigMap do Grafana

Criar ConfigMap com configuração OAuth do Keycloak.

## ✅ Passo 8: Testar Integração

### 8.1 Teste de Login

1. Acesse qualquer serviço (GitLab, SonarQube, Nexus)
2. Deve aparecer botão "Login with Keycloak" ou similar
3. Ao clicar, redireciona para Keycloak
4. Após login no Keycloak, retorna ao serviço autenticado

### 8.2 Verificar Mapeamento de Usuários

- Verificar se usuários do Keycloak aparecem nos serviços
- Verificar se grupos/permissões estão corretos
- Testar logout e novo login

## 🔐 Credenciais Importantes

### Keycloak Admin
- URL: `https://auth.innexar.app`
- Username: `admin`
- Password: (verificar em `kubernetes/secrets.yaml`)

### Serviços (antes da integração)
- GitLab: Primeiro acesso cria senha de root
- SonarQube: `admin` / `admin` (mudar na primeira vez)
- Nexus: `admin` / (senha padrão no primeiro acesso)

## 📝 Notas Importantes

1. **Client Secrets**: Guarde os secrets dos clients do Keycloak em local seguro
2. **Primeiro Login**: Alguns serviços podem exigir configuração inicial antes do OAuth
3. **Grupos**: Configure grupos no Keycloak e mapeie para permissões nos serviços
4. **Logout**: Configure logout global se desejar (Single Logout)

## 🔄 Próximos Passos

1. Configurar grupos e roles no Keycloak
2. Mapear grupos para permissões nos serviços
3. Configurar notificações por email
4. Configurar backup automático do Keycloak
5. Documentar processos de onboarding de novos usuários

---

**Última atualização**: Janeiro 2026

