#!/bin/bash

# Daily Backup Script for Innexar Platform
# Run with: bash scripts/backup-daily.sh

set -e

BACKUP_ROOT="/opt/innexar/backups/daily"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PLATFORM_DIR="/opt/innexar/innexar-platform"

echo "=== Daily Backup Started: $(date) ==="

# Create backup directory
mkdir -p $BACKUP_ROOT

# Change to platform directory
cd $PLATFORM_DIR

# Backup GitLab
echo "Backing up GitLab..."
docker-compose exec -T gitlab gitlab-backup create BACKUP=$TIMESTAMP
docker run --rm \
  -v innexar-platform_gitlab_config:/gitlab/config \
  -v innexar-platform_gitlab_logs:/gitlab/logs \
  -v innexar-platform_gitlab_data:/gitlab/data \
  -v $BACKUP_ROOT:/backup \
  alpine tar czf /backup/gitlab_$TIMESTAMP.tar.gz -C /gitlab .

# Backup SonarQube database
echo "Backing up SonarQube database..."
docker-compose exec -T postgres pg_dump -U sonarqube sonarqube > $BACKUP_ROOT/sonar_db_$TIMESTAMP.sql

# Backup Nexus
echo "Backing up Nexus..."
docker run --rm \
  -v innexar-platform_nexus_data:/nexus-data \
  -v $BACKUP_ROOT:/backup \
  alpine tar czf /backup/nexus_$TIMESTAMP.tar.gz -C /nexus-data .

# Backup Keycloak database
echo "Backing up Keycloak database..."
docker-compose exec -T keycloak-db pg_dump -U keycloak keycloak > $BACKUP_ROOT/keycloak_db_$TIMESTAMP.sql

# Backup configurations (without secrets)
echo "Backing up configurations..."
tar czf $BACKUP_ROOT/configs_$TIMESTAMP.tar.gz \
  --exclude='.env' \
  --exclude='backups' \
  --exclude='logs' \
  --exclude='.git' \
  -C $PLATFORM_DIR .

echo "=== Daily Backup Completed: $(date) ==="

# Cleanup old backups (keep last 7 days)
find $BACKUP_ROOT -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_ROOT -name "*.sql" -mtime +7 -delete

echo "Cleanup completed. Old backups removed."
