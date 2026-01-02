# Correções Aplicadas - Troubleshooting

## ✅ SonarQube - CORRIGIDO

### Problema Identificado
```
ERROR: max virtual memory areas vm.max_map_count [65530] is too low, 
increase to at least [262144]
```

### Solução Aplicada
```bash
# Aumentar vm.max_map_count temporariamente
sudo sysctl -w vm.max_map_count=262144

# Tornar permanente
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Status
✅ **RESOLVIDO** - SonarQube está funcionando (HTTP 200)
- Elasticsearch conectado com sucesso
- Serviço acessível em https://sonar.innexar.app

---

## ⚠️ Keycloak - Em Investigação

### Problema Identificado
- Container está rodando (UP)
- Keycloak funciona quando testado internamente (do Traefik)
- Retorna 404 quando acessado externamente via HTTPS

### Diagnóstico
1. ✅ Keycloak inicia corretamente
2. ✅ Responde internamente (testado do container Traefik)
3. ❌ Retorna 404 externamente
4. ✅ Logs não mostram erros

### Tentativas de Correção
1. Adicionados headers customizados no Traefik
2. Verificado roteamento do Traefik
3. Testado acesso interno (funciona)

### Status Atual
⚠️ **EM INVESTIGAÇÃO**
- Container: Funcionando
- Interno: OK
- Externo: 404

### Próximos Passos Sugeridos
1. Verificar configuração do Keycloak em modo dev
2. Limpar cache do Cloudflare
3. Verificar logs do Traefik para requisições específicas
4. Considerar usar `start` com configuração adequada de hostname

---

## 📋 Comandos Úteis

### Verificar Status
```bash
cd /opt/innexar/innexar-platform
docker compose ps
docker compose logs sonarqube --tail=50
docker compose logs keycloak --tail=50
docker compose logs traefik --tail=50
```

### Testar Serviços
```bash
# SonarQube
curl -k -I https://sonar.innexar.app

# Keycloak
curl -k -I https://auth.innexar.app/realms/master
```

### Reiniciar Serviços
```bash
docker compose restart sonarqube
docker compose restart keycloak
```

---

**Última atualização**: Janeiro 2026
