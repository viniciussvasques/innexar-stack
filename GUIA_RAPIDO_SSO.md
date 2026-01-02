# 🚀 Guia Rápido - Configuração SSO Keycloak (Passo a Passo)

## 📋 Visão Geral

Este guia mostra apenas o **ESSENCIAL** para fazer SSO funcionar. Passo a passo simples e direto.

---

## ✅ PASSO 1: Criar Realm "innexar" (2 minutos)

1. **Acesse**: `https://auth.innexar.app`
2. **Login**: `admin` / `K3ycl0@k_Adm1n_P@ss_2025!`
3. **No canto superior esquerdo**, clique no dropdown que mostra **"master"**
4. Clique em **"Create Realm"**
5. **Realm name**: Digite `innexar` (minúsculas, sem espaços!)
6. **Enabled**: Mantenha ON
7. Clique em **"Create"**

✅ **Feito!** Agora você está no realm "innexar"

---

## ✅ PASSO 2: Criar um Usuário de Teste (3 minutos)

1. No menu lateral, clique em **"Users"**
2. Clique no botão **"Create new user"** (canto superior direito)
3. Preencha:
   - **Username**: `dev1`
   - **Email**: `dev1@innexar.app`
   - ✅ **Email Verified**: Liga (ON)
   - ✅ **Enabled**: Liga (ON)
4. Clique em **"Create"**
5. Vá para a aba **"Credentials"** (no topo)
6. Clique no botão **"Set password"**
7. Preencha:
   - **Password**: `Dev@123456`
   - **Password confirmation**: `Dev@123456`
   - ✅ **Temporary**: Desliga (OFF) - importante!
8. Clique em **"Save"**

✅ **Feito!** Você tem um usuário para testar

---

## ✅ PASSO 3: Criar Client para GitLab (5 minutos)

1. No menu lateral, clique em **"Clients"**
2. Clique no botão **"Create client"**
3. **Client type**: Deixe "OpenID Connect"
4. **Client ID**: Digite `gitlab`
5. Clique em **"Next"**
6. **Client authentication**: Liga (ON)
7. **Authorization**: Desliga (OFF)
8. Clique em **"Next"**
9. Preencha:
   - **Root URL**: `https://git.innexar.app`
   - **Home URL**: `https://git.innexar.app`
   - **Valid redirect URIs**: 
     ```
     https://git.innexar.app/users/auth/openid_connect/callback
     ```
   - **Web origins**: `https://git.innexar.app`
10. Clique em **"Save"**
11. Vá para a aba **"Credentials"** (no topo)
12. **📝 ANOTE O "Client secret"** (você vai precisar!)
13. Copie e salve em algum lugar seguro

✅ **Feito!** Client GitLab criado

---

## ✅ PASSO 4: Criar Client para SonarQube (5 minutos)

1. Ainda em **"Clients"**, clique em **"Create client"**
2. **Client ID**: Digite `sonarqube`
3. Clique em **"Next"** → **"Next"** (mantenha padrões)
4. Preencha:
   - **Root URL**: `https://sonar.innexar.app`
   - **Home URL**: `https://sonar.innexar.app`
   - **Valid redirect URIs**: 
     ```
     https://sonar.innexar.app/oauth2/callback/keycloak
     ```
   - **Web origins**: `https://sonar.innexar.app`
5. Clique em **"Save"**
6. Vá para **"Credentials"**
7. **📝 ANOTE O "Client secret"**

✅ **Feito!** Client SonarQube criado

---

## ✅ PASSO 5: Criar Client para Nexus (5 minutos)

1. Ainda em **"Clients"**, clique em **"Create client"**
2. **Client ID**: Digite `nexus`
3. Clique em **"Next"** → **"Next"**
4. Preencha:
   - **Root URL**: `https://nexus.innexar.app`
   - **Home URL**: `https://nexus.innexar.app`
   - **Valid redirect URIs**: 
     ```
     https://nexus.innexar.app/*
     ```
   - **Web origins**: `https://nexus.innexar.app`
5. Clique em **"Save"**
6. Vá para **"Credentials"**
7. **📝 ANOTE O "Client secret"**

✅ **Feito!** Client Nexus criado

---

## ✅ PASSO 6: Configurar GitLab (10 minutos)

⚠️ **ATENÇÃO**: Esta parte é mais técnica. Precisamos acessar o Rails console do GitLab.

### Opção A: Via Rails Console (Recomendado)

1. **No servidor**, execute:
   ```bash
   kubectl exec -it -n innexar-platform $(kubectl get pod -n innexar-platform -l app=gitlab -o jsonpath='{.items[0].metadata.name}') -- bash
   ```

2. **Dentro do pod**, execute:
   ```bash
   gitlab-rails console
   ```

3. **No console Ruby**, cole e execute (substitua `SEU_CLIENT_SECRET_GITLAB` pelo secret que você anotou):
   ```ruby
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
             secret: 'SEU_CLIENT_SECRET_GITLAB',
             redirect_uri: 'https://git.innexar.app/users/auth/openid_connect/callback'
           }
         }
       }
     ]
   )
   exit
   ```

4. **Saia do pod**: `exit`

5. **Reinicie o GitLab**:
   ```bash
   kubectl rollout restart deployment gitlab -n innexar-platform
   ```

6. Aguarde 2-3 minutos e teste: `https://git.innexar.app`

✅ **Feito!** GitLab configurado

---

## ✅ PASSO 7: Configurar SonarQube (5 minutos)

1. Acesse: `https://sonar.innexar.app`
2. Login inicial: `admin` / `admin` (mude a senha se solicitado)
3. Vá em **Administration** → **Configuration** → **General** → **Authentication**
4. Configure:
   - **Enabled**: ON
   - **Provider**: `OpenID Connect`
   - **Is enabled**: ON
   - **Client ID**: `sonarqube`
   - **Client Secret**: (cole o secret do SonarQube que você anotou)
   - **Issuer URI**: `https://auth.innexar.app/realms/innexar`
   - **Provider name**: `Keycloak`
   - **Allow users to sign-up**: ON (se desejar)
5. Clique em **Save**

✅ **Feito!** SonarQube configurado

---

## ✅ PASSO 8: Configurar Nexus (5 minutos)

1. Acesse: `https://nexus.innexar.app`
2. Login inicial: `admin` / (senha padrão no primeiro acesso)
3. Vá em **Settings** (ícone de engrenagem) → **Security** → **Realms**
4. Arraste **"OIDC Realm"** da coluna "Available" para "Active"
5. Clique em **"Save"**
6. Vá em **Settings** → **Security** → **OIDC Connection**
7. Preencha:
   - **Name**: `Keycloak`
   - **Discovery URI**: `https://auth.innexar.app/realms/innexar/.well-known/openid-configuration`
   - **Client ID**: `nexus`
   - **Client Secret**: (cole o secret do Nexus que você anotou)
   - **Email claim**: `email`
   - **Groups claim**: `groups`
8. Clique em **"Test Connection"** (deve mostrar sucesso)
9. Clique em **"Save"**

✅ **Feito!** Nexus configurado

---

## ✅ PASSO 9: Testar SSO (5 minutos)

### Teste 1: GitLab
1. Acesse: `https://git.innexar.app`
2. Deve aparecer botão **"Keycloak"** ou **"Sign in with Keycloak"**
3. Clique e faça login com: `dev1` / `Dev@123456`
4. Você deve ser redirecionado de volta ao GitLab, já autenticado

### Teste 2: SonarQube
1. Acesse: `https://sonar.innexar.app`
2. Deve aparecer opção de login com Keycloak
3. Faça login com: `dev1` / `Dev@123456`
4. Deve funcionar!

### Teste 3: Nexus
1. Acesse: `https://nexus.innexar.app`
2. Deve mostrar opção de login com Keycloak
3. Faça login com: `dev1` / `Dev@123456`
4. Deve funcionar!

✅ **Tudo funcionando!** 🎉

---

## 📝 Checklist Final

- [ ] Realm "innexar" criado
- [ ] Usuário de teste criado (dev1)
- [ ] Client GitLab criado e secret anotado
- [ ] Client SonarQube criado e secret anotado
- [ ] Client Nexus criado e secret anotado
- [ ] GitLab configurado com OAuth
- [ ] SonarQube configurado com OAuth
- [ ] Nexus configurado com OIDC
- [ ] Testado login em todos os serviços

---

## 🔧 Troubleshooting

### Problema: Redirect URI não funciona
**Solução**: Verifique se o URI está EXATAMENTE igual no Keycloak e no serviço (inclui http/https, barras, etc.)

### Problema: Client secret inválido
**Solução**: Verifique se copiou o secret corretamente (sem espaços extras)

### Problema: Usuário não aparece no serviço
**Solução**: O primeiro login cria o usuário automaticamente. Tente fazer logout e login novamente

---

## 📚 Documentação Completa

Se precisar de mais detalhes, consulte:
- `INTEGRACAO_COMPLETA.md` - Guia completo e detalhado
- `KEYCLOAK_SSO_SETUP.md` - Guia complementar

---

**Tempo total estimado**: 40-50 minutos
**Última atualização**: Janeiro 2026

