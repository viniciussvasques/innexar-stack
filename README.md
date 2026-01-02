# Plataforma Innexar

Infraestrutura completa de DevOps para desenvolvimento colaborativo, utilizando Docker e serviços cloud-native.

## 🏗️ Arquitetura

- **Reverse Proxy**: Traefik com HTTPS automático (Let's Encrypt)
- **Controle de Versão**: GitLab CE
- **Análise de Código**: SonarQube
- **Repositório de Artefatos**: Nexus Repository
- **Gerenciamento de Identidade**: Keycloak
- **Domínio**: innexar.app com subdomínios dedicados

## 🚀 Serviços Disponíveis

| Serviço | URL | Descrição |
|---------|-----|-----------|
| GitLab | https://git.innexar.app | Controle de versão e CI/CD |
| SonarQube | https://sonar.innexar.app | Análise de qualidade de código |
| Nexus | https://nexus.innexar.app | Repositório Maven, NPM, Docker |
| Keycloak | https://auth.innexar.app | SSO e gerenciamento de usuários |
| Traefik | https://traefik.innexar.app | Dashboard de monitoramento |

## 📋 Pré-requisitos

- Ubuntu 22.04 LTS
- Docker Engine 24+
- Docker Compose v2.0+
- 8GB RAM mínimo
- Domínio `innexar.app` adicionado ao Cloudflare
- IP público da VM: **66.93.25.253**

## 🛠️ Instalação Rápida

```bash
# 1. Clonar ou copiar arquivos para /opt/innexar/innexar-platform
cd /opt/innexar/innexar-platform

# 2. Configurar variáveis de ambiente
cp .env.example .env
nano .env  # Editar senhas e configurações

# 3. Validar configuração das variáveis
bash scripts/validate-env.sh

# 4. ⚠️ IMPORTANTE: Adicionar domínio ao Cloudflare (ver CLOUDFLARE_DNS.md)
#    - Adicione innexar.app ao seu Cloudflare
#    - Configure os nameservers no registrador

# 5. Configurar registros DNS automaticamente
bash scripts/setup-cloudflare-dns.sh

# 6. Verificar status do DNS
bash scripts/check-dns.sh

# 7. Iniciar plataforma (método recomendado)
bash scripts/start-platform.sh

# 8. Ou iniciar manualmente
docker-compose up -d
docker-compose ps
```

## 📚 Documentação

- **[Manual Operacional](./OPERATIONAL_MANUAL.md)**: Guias completos de operação, backup e manutenção
- **[Configuração DNS](./CLOUDFLARE_DNS.md)**: Instruções para configuração no Cloudflare
- **[Configuração SSO Keycloak](./KEYCLOAK_SSO_SETUP.md)**: Guia completo para configurar Single Sign-On
- **[Migração para Produção](./PRODUCTION_MIGRATION.md)**: Detalhes da configuração de produção
- **[Solução de Problemas](./TROUBLESHOOTING.md)**: Guias de diagnóstico e resolução

## ⚙️ Variáveis de Ambiente

As seguintes variáveis devem ser configuradas no arquivo `.env`:

### Obrigatórias
- **ACME_EMAIL**: `dev@innexar.app` (para Let's Encrypt)
- **CLOUDFLARE_EMAIL**: Seu email do Cloudflare
- **CLOUDFLARE_API_TOKEN**: Token da API do Cloudflare
- **SMTP_USERNAME/PASSWORD**: Credenciais para notificações GitLab
- **SONAR_DB_PASSWORD**: Senha do banco SonarQube
- **KEYCLOAK_ADMIN_PASSWORD**: Senha admin do Keycloak
- **KEYCLOAK_DB_PASSWORD**: Senha do banco Keycloak

### Opcionais
- **TRAEFIK_BASIC_AUTH**: Hash para acesso ao dashboard Traefik

### Validação
```bash
bash scripts/validate-env.sh
```

## 🔧 Configuração Inicial dos Serviços

### GitLab
1. Acesse https://git.innexar.app
2. Defina senha do root
3. Configure SMTP para notificações

### SonarQube
1. Acesse https://sonar.innexar.app
2. Login: `admin` / `admin`
3. Configure integração com GitLab

### Nexus
1. Acesse https://nexus.innexar.app
2. Login: `admin` / `admin123`
3. Altere senha padrão e configure repositórios

### Keycloak
1. Acesse https://auth.innexar.app
2. Login com credenciais do `.env`
3. Configure realms e clientes
4. **SSO**: Consulte [KEYCLOAK_SSO_SETUP.md](./KEYCLOAK_SSO_SETUP.md) para configurar login único

## 🔒 Segurança

- HTTPS automático com Let's Encrypt
- SSL/TLS Full Strict no Cloudflare
- Autenticação Basic Auth no Traefik Dashboard
- Redes Docker isoladas
- Volumes persistentes para dados

## 📊 Monitoramento

- Dashboard Traefik: https://traefik.innexar.app
- Logs centralizados via Docker Compose
- Métricas Prometheus (futuro)
- Alertas automáticos (futuro)

## 🛠️ Scripts Disponíveis

```bash
# Validação da configuração
bash scripts/validate-env.sh

# Configuração automática do DNS no Cloudflare
bash scripts/setup-cloudflare-dns.sh

# Verificação do status do DNS
bash scripts/check-dns.sh

# Inicialização completa da plataforma
bash scripts/start-platform.sh

# Obter informações do Keycloak para SSO
bash scripts/get-keycloak-info.sh

# Backup diário
bash scripts/backup-daily.sh
```

## 🚀 Comandos Essenciais

```bash
# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f

# Reiniciar serviço
docker-compose restart gitlab

# Parar tudo
docker-compose down
```

## 🤝 Suporte

- **Issues**: Criar no GitLab do projeto
- **Documentação**: https://docs.innexar.app
- **Administrador**: admin@innexar.app

## 📝 Notas de Versão

### v1.0.0 (Janeiro 2026)
- ✅ Infraestrutura base completa
- ✅ Configuração Traefik com HTTPS
- ✅ Integração GitLab + SonarQube + Nexus + Keycloak
- ✅ Scripts de backup automatizados
- ✅ Manual operacional completo
- ✅ Documentação Cloudflare DNS

---

**Innexar** - Plataforma DevOps para desenvolvimento colaborativo
