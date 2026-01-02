#!/bin/bash

# Platform Startup Script
# Run with: bash scripts/start-platform.sh

echo "🚀 Starting Innexar Platform..."
echo

# Validate environment first
echo "📋 Validating configuration..."
bash scripts/validate-env.sh

if [ $? -ne 0 ]; then
    echo "❌ Configuration validation failed. Please fix the issues above."
    exit 1
fi

echo
echo "✅ Configuration validated successfully!"
echo

# Start services
echo "🐳 Starting Docker services..."
docker compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start services"
    exit 1
fi

echo
echo "⏳ Waiting for services to initialize (this may take a few minutes)..."
sleep 30

# Check service status
echo "📊 Checking service status..."
docker compose ps

echo
echo "🔍 Checking service health..."
echo

# Test Traefik
echo "Testing Traefik..."
curl -k -s -o /dev/null -w "   Traefik: %{http_code}\n" https://traefik.innexar.app || echo "   Traefik: Connection failed (DNS may still propagating)"

# Test services (may fail initially during startup)
echo "Testing GitLab..."
curl -k -s -o /dev/null -w "   GitLab: %{http_code}\n" https://git.innexar.app || echo "   GitLab: Still starting up..."

echo "Testing SonarQube..."
curl -k -s -o /dev/null -w "   SonarQube: %{http_code}\n" https://sonar.innexar.app || echo "   SonarQube: Still starting up..."

echo "Testing Nexus..."
curl -k -s -o /dev/null -w "   Nexus: %{http_code}\n" https://nexus.innexar.app || echo "   Nexus: Still starting up..."

echo "Testing Keycloak..."
curl -k -s -o /dev/null -w "   Keycloak: %{http_code}\n" https://auth.innexar.app || echo "   Keycloak: Still starting up..."

echo
echo "🎉 Platform startup initiated!"
echo
echo "📝 Next steps:"
echo "   1. Monitor logs: docker-compose logs -f"
echo "   2. Wait for DNS propagation (may take 24h)"
echo "   3. Access services at the URLs above"
echo "   4. Set up backup: bash scripts/backup-daily.sh"
echo
echo "🔐 Default credentials:"
echo "   - Traefik Dashboard: admin / Innexar2025!"
echo "   - GitLab: Configure on first access"
echo "   - SonarQube: admin / admin (change immediately)"
echo "   - Nexus: admin / admin123 (change immediately)"
echo "   - Keycloak: admin / K3ycl0@k_Adm1n_P@ss_2025!"
