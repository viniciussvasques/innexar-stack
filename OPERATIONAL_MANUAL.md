# Manual Operacional - Plataforma Innexar

## Visão Geral

Este manual descreve as operações diárias da plataforma Innexar, incluindo inicialização, parada, backup e integração de novos desenvolvedores.

**Localização**: `/opt/innexar/innexar-platform`
**Stack**: Docker Compose com Traefik, GitLab, SonarQube, Nexus e Keycloak

## Pré-requisitos

### Sistema
- Ubuntu 22.04 LTS
- Docker Engine 24+
- Docker Compose v2.0+
- 8GB RAM mínimo (16GB recomendado)
- 100GB espaço em disco mínimo

### Acesso
- Usuário com privilégios sudo
- Chaves SSH configuradas
- Acesso ao Cloudflare para gerenciamento DNS

### Instalação Inicial

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version
```

## Inicialização da Plataforma

### Primeira Inicialização

```bash
cd /opt/innexar/innexar-platform

# 1. Configurar variáveis de ambiente
cp .env.example .env
nano .env  # Editar senhas e configurações

# 2. Gerar hash para Basic Auth do Traefik
sudo apt install apache2-utils
htpasswd -nb admin "sua-senha-segura" >> .env

# 3. Iniciar serviços
docker-compose up -d

# 4. Verificar inicialização
docker-compose ps
docker-compose logs -f
```

### Ordem de Inicialização
1. **Traefik** (reverse proxy)
2. **GitLab** (sistema de controle de versão)
3. **PostgreSQL + SonarQube** (análise de código)
4. **Nexus** (repositório de artefatos)
5. **PostgreSQL + Keycloak** (gerenciamento de identidade)

### Verificação de Saúde

```bash
# Verificar status de todos os serviços
docker-compose ps

# Verificar logs em tempo real
docker-compose logs -f [nome-do-servico]

# Testar conectividade
curl -k https://git.innexar.app
curl -k https://sonar.innexar.app
curl -k https://nexus.innexar.app
curl -k https://auth.innexar.app
```

## Parada da Plataforma

### Parada Controlada

```bash
cd /opt/innexar/innexar-platform

# Parar todos os serviços
docker-compose down

# Parar com remoção de volumes (CUIDADO!)
# docker-compose down -v
```

### Parada de Emergência

```bash
# Forçar parada
docker-compose kill

# Limpar containers órfãos
docker system prune -f
```

## Backup e Restauração

### Estratégia de Backup

**Frequência**:
- Dados críticos: Diariamente
- Configurações: Semanalmente
- Logs: Rotação automática

**Localização**: `/opt/innexar/backups`

### Scripts de Backup

#### Criar estrutura de backup
```bash
mkdir -p /opt/innexar/backups/{gitlab,sonarqube,nexus,keycloak,daily,weekly}
```

#### Backup do GitLab
```bash
#!/bin/bash
# backup-gitlab.sh

BACKUP_DIR="/opt/innexar/backups/gitlab"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup dos volumes
docker run --rm \
  -v gitlab_gitlab_config:/gitlab/config \
  -v gitlab_gitlab_logs:/gitlab/logs \
  -v gitlab_gitlab_data:/gitlab/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/gitlab_$TIMESTAMP.tar.gz -C /gitlab .

# Backup do banco de dados
docker exec gitlab gitlab-backup create BACKUP=$TIMESTAMP
```

#### Backup do SonarQube
```bash
#!/bin/bash
# backup-sonarqube.sh

BACKUP_DIR="/opt/innexar/backups/sonarqube"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup do banco PostgreSQL
docker exec postgres-sonarqube pg_dump -U sonarqube sonarqube > $BACKUP_DIR/sonar_db_$TIMESTAMP.sql

# Backup dos volumes
docker run --rm \
  -v sonarqube_sonarqube_data:/sonarqube/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/sonarqube_data_$TIMESTAMP.tar.gz -C /sonarqube .
```

#### Backup do Nexus
```bash
#!/bin/bash
# backup-nexus.sh

BACKUP_DIR="/opt/innexar/backups/nexus"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup do volume de dados
docker run --rm \
  -v nexus_nexus_data:/nexus-data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/nexus_$TIMESTAMP.tar.gz -C /nexus-data .
```

#### Backup do Keycloak
```bash
#!/bin/bash
# backup-keycloak.sh

BACKUP_DIR="/opt/innexar/backups/keycloak"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup do banco PostgreSQL
docker exec postgres-keycloak pg_dump -U keycloak keycloak > $BACKUP_DIR/keycloak_db_$TIMESTAMP.sql

# Backup dos dados do Keycloak
docker run --rm \
  -v keycloak_keycloak_data:/keycloak/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/keycloak_data_$TIMESTAMP.tar.gz -C /keycloak .
```

### Automação com Cron

```bash
# Editar crontab
sudo crontab -e

# Backup diário às 2:00 AM
0 2 * * * /opt/innexar/innexar-platform/scripts/backup-daily.sh

# Backup semanal aos domingos às 3:00 AM
0 3 * * 0 /opt/innexar/innexar-platform/scripts/backup-weekly.sh

# Limpeza de backups antigos (30 dias para daily, 90 para weekly)
0 4 * * * find /opt/innexar/backups/daily -name "*.tar.gz" -mtime +30 -delete
0 4 * * 0 find /opt/innexar/backups/weekly -name "*.tar.gz" -mtime +90 -delete
```

### Restauração

#### Restaurar GitLab
```bash
# Parar GitLab
docker-compose stop gitlab

# Restaurar backup
docker run --rm \
  -v gitlab_gitlab_data:/gitlab/data \
  -v $BACKUP_DIR:/backup \
  alpine sh -c "cd /gitlab && tar xzf /backup/gitlab_backup.tar.gz"

# Reiniciar
docker-compose start gitlab
```

## Integração de Novos Desenvolvedores

### Pré-requisitos para Desenvolvedores

1. **Acesso SSH** ao servidor
2. **Conta GitLab** criada
3. **Acesso aos repositórios** necessários
4. **Configuração Git** local
5. **Acesso SonarQube** para análise de código

### Processo de Onboarding

#### 1. Configuração Inicial do Servidor

```bash
# Adicionar usuário do desenvolvedor
sudo useradd -m -s /bin/bash nome-desenvolvedor
sudo usermod -aG docker nome-desenvolvedor

# Configurar chaves SSH
sudo mkdir -p /home/nome-desenvolvedor/.ssh
sudo cp /root/.ssh/authorized_keys /home/nome-desenvolvedor/.ssh/
sudo chown -R nome-desenvolvedor:nome-desenvolvedor /home/nome-desenvolvedor/.ssh
sudo chmod 700 /home/nome-desenvolvedor/.ssh
sudo chmod 600 /home/nome-desenvolvedor/.ssh/authorized_keys
```

#### 2. Acesso ao GitLab

1. Acessar https://git.innexar.app
2. Criar conta ou fazer login
3. Administrador concede acesso aos projetos
4. Configurar chave SSH para Git

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "nome@innexar.app"

# Adicionar ao GitLab (Settings > SSH Keys)
cat ~/.ssh/id_ed25519.pub
```

#### 3. Configuração Git Local

```bash
# Configurar Git
git config --global user.name "Nome Completo"
git config --global user.email "nome@innexar.app"
git config --global core.editor "nano"
git config --global init.defaultBranch main

# Configurar SSH para GitLab
git config --global url."git@git.innexar.app:".insteadOf "https://git.innexar.app/"
```

#### 4. Acesso ao SonarQube

1. Acessar https://sonar.innexar.app
2. Fazer login (integração com GitLab)
3. Receber permissões do administrador

#### 5. Acesso ao Nexus

1. Acessar https://nexus.innexar.app
2. Credenciais fornecidas pelo administrador
3. Configurar acesso nos projetos (settings.xml, .npmrc, etc.)

#### 6. Acesso ao Keycloak (se necessário)

1. Para aplicações que usam autenticação centralizada
2. Credenciais fornecidas pelo administrador

### Documentação para Desenvolvedores

Criar arquivo `DEVELOPER_SETUP.md`:

```markdown
# Configuração do Ambiente de Desenvolvimento

## Acesso aos Serviços

- **GitLab**: https://git.innexar.app
- **SonarQube**: https://sonar.innexar.app
- **Nexus**: https://nexus.innexar.app
- **Documentação**: https://docs.innexar.app

## Configuração Git

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@empresa.com"
```

## Publicação no Nexus

### Maven
Adicionar ao `settings.xml`:
```xml
<server>
  <id>nexus</id>
  <username>seu-usuario</username>
  <password>token-gerado</password>
</server>
```

### NPM
```bash
npm config set registry https://nexus.innexar.app/repository/npm-group/
//nexus.innexar.app/repository/npm-group/:_authToken=token-gerado
```
```

## Monitoramento e Troubleshooting

### Logs

```bash
# Logs de todos os serviços
docker-compose logs -f

# Logs específicos
docker-compose logs -f gitlab
docker-compose logs -f sonarqube

# Logs com timestamps
docker-compose logs --timestamps
```

### Monitoramento de Recursos

```bash
# Uso de disco
df -h

# Uso de memória e CPU
docker stats

# Volumes Docker
docker system df -v
```

### Problemas Comuns

#### GitLab não inicia
```bash
# Verificar configuração
docker-compose exec gitlab gitlab-ctl status

# Reconfigurar
docker-compose exec gitlab gitlab-ctl reconfigure

# Verificar logs detalhados
docker-compose exec gitlab gitlab-ctl tail
```

#### SonarQube lento
```bash
# Verificar banco de dados
docker-compose exec postgres pg_isready -U sonarqube

# Otimizar PostgreSQL
docker-compose exec postgres psql -U sonarqube -d sonarqube -c "VACUUM ANALYZE;"
```

#### Certificados SSL
```bash
# Renovar manualmente
docker-compose exec traefik traefik --certificatesResolvers.letsencrypt.acme.caserver=https://acme-v02.api.letsencrypt.org/directory

# Verificar certificados
curl -v https://git.innexar.app
```

### Alertas e Notificações

Configurar alertas para:
- Espaço em disco < 10%
- Memória RAM alta
- Serviços fora do ar
- Falhas de backup

## Segurança

### Práticas Recomendadas

1. **Atualizações Regulares**
   ```bash
   # Atualizar imagens Docker
   docker-compose pull
   docker-compose up -d

   # Atualizar sistema
   sudo apt update && sudo apt upgrade
   ```

2. **Auditoria de Logs**
   ```bash
   # Logs de acesso Traefik
   docker-compose logs traefik | grep -i "unauthorized"

   # Logs de segurança GitLab
   docker-compose exec gitlab gitlab-ctl tail /var/log/gitlab/gitlab-rails/production.log
   ```

3. **Backup de Configurações Sensíveis**
   - Arquivo `.env` criptografado
   - Chaves SSH em local seguro
   - Credenciais administrativas

### Checklist de Segurança

- [ ] Senhas fortes configuradas
- [ ] Acesso SSH com chaves (não senha)
- [ ] Firewall configurado
- [ ] SSL/TLS Full Strict no Cloudflare
- [ ] Certificados Let's Encrypt válidos
- [ ] Backup criptografado
- [ ] Logs auditados regularmente

## Suporte e Contato

**Administrador da Plataforma**: admin@innexar.app
**Documentação Técnica**: https://docs.innexar.app
**Issues e Suporte**: Criar issue no GitLab do projeto

---

*Última atualização: Janeiro 2026*
