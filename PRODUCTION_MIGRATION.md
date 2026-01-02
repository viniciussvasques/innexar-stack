# Migração para Produção - Plataforma Innexar

Este documento descreve as mudanças aplicadas para colocar a plataforma em modo produção.

## 🔄 Mudanças Aplicadas

### 1. Keycloak - Modo Produção

**Antes (Desenvolvimento):**
```yaml
command: start-dev --http-port=8080 --hostname-strict=false
```

**Depois (Produção):**
```yaml
command: start --http-port=8080 --hostname-strict=false
```

**Mudanças:**
- ✅ `start-dev` → `start` (modo produção)
- ⚠️ **Nota**: `--optimized` requer build prévio, usando `start` padrão
- ✅ Adicionadas configurações de proxy (`KC_PROXY: edge`)
- ✅ Adicionadas configurações de headers (`KC_PROXY_HEADERS: xforwarded`)
- ✅ Configurações JVM otimizadas para containers
- ✅ Healthcheck configurado

### 2. Docker Compose

**Removido:**
- ❌ `version: '3.8'` (obsoleto no Docker Compose v2)

## 📋 Passos para Aplicar Mudanças

### 1. Parar o Keycloak

```bash
cd /opt/innexar/innexar-platform
docker compose stop keycloak
```

### 2. Fazer Backup (Recomendado)

```bash
# Backup do volume do Keycloak
docker run --rm \
  -v innexar-platform_keycloak_data:/keycloak-data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/keycloak-data-$(date +%Y%m%d-%H%M%S).tar.gz -C /keycloak-data .
```

### 3. Reiniciar com Nova Configuração

```bash
docker compose up -d keycloak
```

### 4. Verificar Status

```bash
# Ver logs do Keycloak
docker compose logs -f keycloak

# Verificar health
docker compose ps keycloak

# Testar acesso
curl -k https://auth.innexar.app/health/ready
```

## ⚠️ Importante

### Keycloak em Modo Produção

O Keycloak já foi inicializado em modo dev, então os dados existentes serão preservados. O modo `start --optimized` usará os dados existentes no volume.

**Se você está iniciando do zero:**
1. Primeira inicialização: Use `start-dev` para configurar o admin
2. Após configuração inicial: Mude para `start --optimized`

**Neste caso:** Como já temos dados, a mudança é direta.

## 🔒 Configurações de Segurança Aplicadas

### Keycloak
- ✅ Proxy mode: `edge` (HTTPS terminado no Traefik)
- ✅ Headers: `xforwarded` (reconhece headers do proxy reverso)
- ✅ JVM otimizado para containers
- ✅ Healthcheck configurado

### Traefik
- ✅ HTTPS com Let's Encrypt
- ✅ SSL/TLS Full Strict no Cloudflare
- ✅ Dashboard protegido com Basic Auth

## 📊 Verificação Pós-Migração

Execute os seguintes testes:

```bash
# 1. Verificar todos os serviços
docker compose ps

# 2. Verificar Keycloak
curl -k https://auth.innexar.app/health/ready
curl -k https://auth.innexar.app/health/live

# 3. Verificar GitLab
curl -k -I https://git.innexar.app

# 4. Verificar SonarQube
curl -k -I https://sonar.innexar.app

# 5. Verificar Nexus
curl -k -I https://nexus.innexar.app
```

## 🚀 Próximos Passos Recomendados

1. **Configurar SSO** (se ainda não feito):
   - Consulte `KEYCLOAK_SSO_SETUP.md`

2. **Otimizar Recursos**:
   - Ajustar limites de memória conforme necessário
   - Configurar limites de CPU se necessário

3. **Monitoramento**:
   - Configurar alertas
   - Monitorar logs regularmente

4. **Backups**:
   - Automatizar backups diários
   - Testar restauração periodicamente

## 📝 Notas

- **Keycloak em produção**: Requer mais memória que modo dev
- **Primeira inicialização**: Pode levar mais tempo (30-60 segundos)
- **Dados preservados**: Todos os realms, clients e usuários são preservados

---

**Data da Migração**: Janeiro 2026
