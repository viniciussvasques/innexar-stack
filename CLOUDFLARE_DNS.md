# Cloudflare DNS Configuration - Innexar Platform

## Pré-requisitos
- Domínio `innexar.app` registrado e configurado no Cloudflare
- IP público do servidor VPS/Ubuntu: **66.93.25.253**
- SSL/TLS mode: **Full (Strict)**

## ⚠️ PASSO IMPORTANTE: Adicionar Domínio ao Cloudflare

Antes de executar qualquer script, você **DEVE** adicionar o domínio `innexar.app` à sua conta Cloudflare:

1. Acesse [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Clique em **"Add a domain"**
3. Digite: `innexar.app`
4. Selecione seu plano (gratuito está OK)
5. Cloudflare irá mostrar os nameservers
6. **ANOTE OS NAMESERVERS** que aparecem
7. Vá ao registrador do domínio e altere os nameservers para os fornecidos pelo Cloudflare
8. Aguarde até 24h para a propagação

## Configuração do Token API Cloudflare

### 1. Gerar Token API
1. Acesse [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Vá para **My Profile** → **API Tokens**
3. Clique em **Create Token**
4. Selecione **Create Custom Token**
5. Configure as permissões:
   - **Account**: Cloudflare Pages (Read)
   - **Zone**: DNS (Edit)
   - **Zone**: Zone (Read)
6. Clique em **Continue to summary** → **Create Token**
7. **COPIE E SALVE O TOKEN** (não poderá vê-lo novamente)

### 2. Configurar no Arquivo .env
```bash
# Edite o arquivo .env e adicione:
CLOUDFLARE_EMAIL=seu-email@exemplo.com
CLOUDFLARE_API_TOKEN=seu-token-aqui
```

## Registros DNS Necessários

### Registro Principal
```
Tipo: A
Nome: @
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

### Subdomínios dos Serviços

#### GitLab
```
Tipo: A
Nome: git
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### SonarQube
```
Tipo: A
Nome: sonar
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Nexus Repository
```
Tipo: A
Nome: nexus
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Keycloak (Auth)
```
Tipo: A
Nome: auth
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Grafana
```
Tipo: A
Nome: grafana
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Prometheus (Monitor)
```
Tipo: A
Nome: monitor
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Traefik Dashboard (Opcional - Acesso Interno)
```
Tipo: A
Nome: traefik
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

#### Documentação
```
Tipo: A
Nome: docs
Valor: YOUR_SERVER_IP
Proxy: Proxied (laranja)
TTL: Auto
```

## Configuração SSL/TLS no Cloudflare

1. Acesse seu domínio no Cloudflare Dashboard
2. Vá para **SSL/TLS** → **Overview**
3. Defina o modo SSL/TLS para: **Full (Strict)**
4. Vá para **SSL/TLS** → **Edge Certificates**
5. Ative: **Always Use HTTPS**
6. Ative: **Automatic HTTPS Rewrites**

## Verificação

Após criar os registros DNS, aguarde a propagação (pode levar até 24 horas) e verifique:

```bash
# Verificar resolução DNS
nslookup git.innexar.app
nslookup sonar.innexar.app
nslookup nexus.innexar.app
nslookup auth.innexar.app

# Testar conectividade HTTPS
curl -I https://git.innexar.app
curl -I https://sonar.innexar.app
curl -I https://nexus.innexar.app
curl -I https://auth.innexar.app
curl -I https://grafana.innexar.app
curl -I https://monitor.innexar.app
```

## URLs de Acesso

Após configuração completa:
- **GitLab**: https://git.innexar.app
- **SonarQube**: https://sonar.innexar.app
- **Nexus**: https://nexus.innexar.app
- **Keycloak**: https://auth.innexar.app
- **Grafana**: https://grafana.innexar.app
- **Prometheus**: https://monitor.innexar.app
- **Traefik Dashboard**: https://traefik.innexar.app (protegido por Basic Auth)
