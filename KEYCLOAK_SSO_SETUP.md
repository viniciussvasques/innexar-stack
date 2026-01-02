# Configuração SSO com Keycloak - Plataforma Innexar

Este guia explica como configurar Single Sign-On (SSO) usando Keycloak como provedor de identidade central para todos os serviços da plataforma.

## 📋 Visão Geral

Com o SSO configurado, os usuários poderão fazer login uma única vez no Keycloak e ter acesso automático a:
- **GitLab** (via OAuth2/OpenID Connect)
- **SonarQube** (via OAuth2/OpenID Connect)
- **Nexus Repository** (via OAuth2/OpenID Connect)

## 🎯 Pré-requisitos

1. Keycloak rodando e acessível em https://auth.innexar.app
2. Todos os serviços (GitLab, SonarQube, Nexus) em funcionamento
3. Acesso administrativo ao Keycloak

## 🔧 Passo 1: Configuração Inicial do Keycloak

### 1.1. Acessar o Keycloak Admin Console

1. Acesse: **https://auth.innexar.app**
2. Clique em **"Administration Console"**
3. Faça login com as credenciais:
   - **Usuário**: `admin`
   - **Senha**: `K3ycl0@k_Adm1n_P@ss_2025!`

### 1.2. Criar Realm "innexar"

1. No menu superior, clique no dropdown que mostra **"master"**
2. Clique em **"Create Realm"**
3. Preencha:
   - **Realm name**: `innexar`
4. Clique em **"Create"**

### 1.3. Configurar Realm Settings

1. No menu lateral, vá em **Realm Settings** → **General**
2. Configure:
   - **Display name**: `Innexar Platform`
   - **HTML Display name**: `Innexar Platform`
3. Vá para a aba **Login**
4. Ative:
   - ✅ **User registration**: `ON` (opcional)
   - ✅ **Forgot password**: `ON`
   - ✅ **Remember me**: `ON`
5. Clique em **"Save"**

### 1.4. Criar Usuários de Teste

1. No menu lateral, vá em **Users**
2. Clique em **"Create new user"**
3. Preencha:
   - **Username**: `dev1`
   - **Email**: `dev1@innexar.app`
   - ✅ **Email Verified**: `ON`
4. Clique em **"Create"**
5. Vá para a aba **Credentials**
6. Clique em **"Set password"**
7. Preencha:
   - **Password**: `Dev@123456`
   - **Password confirmation**: `Dev@123456`
   - ✅ **Temporary**: `OFF`
8. Clique em **"Save"**

Repita para criar mais usuários conforme necessário.

## 🔐 Passo 2: Configurar Client para GitLab

### 2.1. Criar Client no Keycloak

1. No menu lateral, vá em **Clients**
2. Clique em **"Create client"**
3. Preencha:
   - **Client type**: `OpenID Connect`
   - **Client ID**: `gitlab`
4. Clique em **"Next"**

### 2.2. Configurar Capabilities

- ✅ **Client authentication**: `ON`
- ✅ **Authorization**: `OFF`
- ✅ **Authentication flow**: `Standard flow`, `Direct access grants`
- Clique em **"Next"**

### 2.3. Configurar Login Settings

1. Preencha:
   - **Root URL**: `https://git.innexar.app`
   - **Home URL**: `https://git.innexar.app`
   - **Valid redirect URIs**: `https://git.innexar.app/users/auth/openid_connect/callback`
   - **Valid post logout redirect URIs**: `https://git.innexar.app`
   - **Web origins**: `https://git.innexar.app`
2. Clique em **"Save"**

### 2.4. Obter Credenciais do Client

1. Vá para a aba **Credentials**
2. **ANOTE** o **Client secret** (você precisará dele)

### 2.5. Configurar Mappers

1. Vá para a aba **Client scopes**
2. Clique em **"gitlab-dedicated"**
3. Vá para a aba **Mappers**
4. Clique em **"Add mapper"** → **"By configuration"**
5. Adicione os seguintes mappers:

**Mapper 1: Username**
- **Mapper type**: `User Attribute`
- **Name**: `username`
- **User Attribute**: `username`
- **Token Claim Name**: `preferred_username`
- ✅ **Add to ID token**: `ON`
- ✅ **Add to access token**: `ON`

**Mapper 2: Email**
- **Mapper type**: `User Property`
- **Name**: `email`
- **Property**: `email`
- **Token Claim Name**: `email`
- ✅ **Add to ID token**: `ON`
- ✅ **Add to access token**: `ON`

**Mapper 3: Groups (opcional)**
- **Mapper type**: `Group Membership`
- **Name**: `groups`
- **Token Claim Name**: `groups`
- ✅ **Full group path**: `OFF`
- ✅ **Add to ID token**: `ON`

## 🔐 Passo 3: Configurar Client para SonarQube

### 3.1. Criar Client no Keycloak

1. No menu lateral, vá em **Clients**
2. Clique em **"Create client"**
3. Preencha:
   - **Client type**: `OpenID Connect`
   - **Client ID**: `sonarqube`
4. Clique em **"Next"**

### 3.2. Configurar Capabilities

- ✅ **Client authentication**: `ON`
- ✅ **Authorization**: `OFF`
- ✅ **Authentication flow**: `Standard flow`, `Direct access grants`
- Clique em **"Next"**

### 3.3. Configurar Login Settings

1. Preencha:
   - **Root URL**: `https://sonar.innexar.app`
   - **Home URL**: `https://sonar.innexar.app`
   - **Valid redirect URIs**: `https://sonar.innexar.app/oauth2/callback/keycloak`
   - **Valid post logout redirect URIs**: `https://sonar.innexar.app`
   - **Web origins**: `https://sonar.innexar.app`
2. Clique em **"Save"**

### 3.4. Obter Credenciais do Client

1. Vá para a aba **Credentials**
2. **ANOTE** o **Client secret**

## 🔐 Passo 4: Configurar Client para Nexus

### 4.1. Criar Client no Keycloak

1. No menu lateral, vá em **Clients**
2. Clique em **"Create client"**
3. Preencha:
   - **Client type**: `OpenID Connect`
   - **Client ID**: `nexus`
4. Clique em **"Next"**

### 4.2. Configurar Capabilities

- ✅ **Client authentication**: `ON`
- ✅ **Authorization**: `OFF`
- ✅ **Authentication flow**: `Standard flow`, `Direct access grants`
- Clique em **"Next"**

### 4.3. Configurar Login Settings

1. Preencha:
   - **Root URL**: `https://nexus.innexar.app`
   - **Home URL**: `https://nexus.innexar.app`
   - **Valid redirect URIs**: `https://nexus.innexar.app/oauth2/callback`
   - **Valid post logout redirect URIs**: `https://nexus.innexar.app`
   - **Web origins**: `https://nexus.innexar.app`
2. Clique em **"Save"**

### 4.4. Obter Credenciais do Client

1. Vá para a aba **Credentials**
2. **ANOTE** o **Client secret**

### 4.5. Obter URLs do Keycloak

1. No menu lateral, vá em **Realm Settings** → **Endpoints**
2. Selecione **OpenID Endpoint Configuration**
3. **ANOTE** as URLs importantes:
   - **Issuer**: `https://auth.innexar.app/realms/innexar`
   - **Authorization Endpoint**: `https://auth.innexar.app/realms/innexar/protocol/openid-connect/auth`
   - **Token Endpoint**: `https://auth.innexar.app/realms/innexar/protocol/openid-connect/token`
   - **Userinfo Endpoint**: `https://auth.innexar.app/realms/innexar/protocol/openid-connect/userinfo`
   - **JWK Set**: `https://auth.innexar.app/realms/innexar/protocol/openid-connect/certs`

## 🔧 Passo 5: Configurar GitLab para Usar Keycloak

### 5.1. Acessar GitLab Admin

1. Acesse: **https://git.innexar.app**
2. Faça login como **root** (ou outro admin)
3. Defina a senha do root se ainda não definiu

### 5.2. Configurar OAuth Application

1. No GitLab, vá em **Menu** → **Admin** → **Settings** → **General**
2. Expanda a seção **"Authentication"**
3. Expanda **"OAuth"**
4. Clique em **"Expand"** em **"OmniAuth Settings"**
5. Adicione a configuração OIDC:

```ruby
gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_ldap_user'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = false
gitlab_rails['omniauth_providers'] = [
  {
    name: 'openid_connect',
    label: 'Keycloak',
    icon: '<svg>...</svg>',
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
```

**⚠️ IMPORTANTE**: Substitua `SEU_CLIENT_SECRET_AQUI` pelo Client Secret que você anotou no Passo 2.4.

### 5.3. Aplicar Configuração

1. Salve o arquivo de configuração
2. Execute no servidor:
```bash
cd /opt/innexar/innexar-platform
docker compose exec gitlab gitlab-ctl reconfigure
docker compose restart gitlab
```

### 5.4. Verificar Login

1. Acesse: **https://git.innexar.app/users/sign_in**
2. Você deve ver um botão **"Keycloak"** ou **"Sign in with OpenID Connect"**
3. Clique e teste o login

## 🔧 Passo 6: Configurar SonarQube para Usar Keycloak

### 6.1. Instalar Plugin OAuth2

O SonarQube Community Edition não suporta OAuth2 nativamente. Você precisará:
- **Opção 1**: Usar SonarQube Developer Edition (pago)
- **Opção 2**: Usar plugin de terceiros
- **Opção 3**: Configurar manualmente via propriedades

### 6.2. Configuração Manual (Community Edition)

1. Acesse: **https://sonar.innexar.app**
2. Faça login como **admin** (senha padrão: `admin`)
3. Vá em **Administration** → **Configuration** → **General** → **Security**
4. Configure:

**SonarQube Authentication:**
- **Allow users to sign up**: `OFF`
- **Force authentication**: `ON`

**OAuth2 Configuration:**
- Adicione as propriedades:

```properties
sonar.auth.oidc.enabled=true
sonar.auth.oidc.providerName=Keycloak
sonar.auth.oidc.clientId.secured=sonarqube
sonar.auth.oidc.clientSecret.secured=SEU_CLIENT_SECRET_AQUI
sonar.auth.oidc.issuerUri=https://auth.innexar.app/realms/innexar
sonar.auth.oidc.sonarServerUrl=https://sonar.innexar.app
sonar.auth.oidc.groupsSync.claimName=groups
```

**⚠️ IMPORTANTE**: Substitua `SEU_CLIENT_SECRET_AQUI` pelo Client Secret do SonarQube.

### 6.3. Reiniciar SonarQube

```bash
cd /opt/innexar/innexar-platform
docker compose restart sonarqube
```

## 🔧 Passo 7: Configurar Nexus para Usar Keycloak

### 7.1. Acessar Nexus Admin

1. Acesse: **https://nexus.innexar.app**
2. Faça login como **admin** (senha padrão: `admin123`)
3. Vá em **Settings** (ícone de engrenagem) → **Security** → **Realms**
4. Ative **"OIDC Realm"** (arraste para a coluna "Active")
5. Clique em **"Save"**

### 7.2. Configurar OIDC Connection

1. Vá em **Settings** → **Security** → **OIDC Connection**
2. Preencha:

```
Name: Keycloak
Discovery URI: https://auth.innexar.app/realms/innexar/.well-known/openid-configuration
Client ID: nexus
Client Secret: SEU_CLIENT_SECRET_AQUI
Email claim: email
Groups claim: groups
```

**⚠️ IMPORTANTE**: Substitua `SEU_CLIENT_SECRET_AQUI` pelo Client Secret do Nexus.

3. Clique em **"Test Connection"** para verificar
4. Clique em **"Save"**

### 7.3. Configurar Role Mapping (Opcional)

1. Vá em **Settings** → **Security** → **Roles**
2. Crie roles conforme necessário
3. Configure mapeamento de grupos do Keycloak para roles do Nexus

## ✅ Passo 8: Testar SSO Completo

### 8.1. Fluxo de Teste

1. **Acesse GitLab**: https://git.innexar.app
2. Clique em **"Sign in with Keycloak"**
3. Faça login no Keycloak
4. Você será redirecionado de volta ao GitLab, já autenticado
5. Acesse SonarQube: https://sonar.innexar.app
6. Você deve estar automaticamente autenticado (ou ver botão Keycloak)
7. Acesse Nexus: https://nexus.innexar.app
8. Você deve estar automaticamente autenticado

### 8.2. Troubleshooting

**Problema**: Erro de redirect URI
- **Solução**: Verifique se o redirect URI no Keycloak está exatamente igual ao configurado no serviço

**Problema**: Client secret inválido
- **Solução**: Verifique se copiou o Client Secret corretamente do Keycloak

**Problema**: Usuário não sincronizado
- **Solução**: Configure os mappers no Keycloak corretamente

## 📝 Notas Importantes

1. **Segurança**: Mantenha os Client Secrets em local seguro (use variáveis de ambiente)
2. **SSL**: Todos os serviços devem usar HTTPS
3. **Session Timeout**: Configure timeouts apropriados no Keycloak
4. **User Provisioning**: Configure mapeamento de grupos/roles conforme necessário
5. **Backup**: Faça backup das configurações do Keycloak regularmente

## 🔄 Próximos Passos

- Configurar grupos e roles no Keycloak
- Mapear grupos para permissões em cada serviço
- Configurar MFA (Multi-Factor Authentication) no Keycloak
- Implementar Just-In-Time (JIT) user provisioning

---

**Última atualização**: Janeiro 2026
