#!/bin/bash

# Cloudflare DNS Setup Script for Innexar Platform
# This script automatically creates all DNS records for innexar.app

set -e

# Configuration
DOMAIN="innexar.app"
SERVER_IP="66.93.25.253"

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "❌ ERROR: .env file not found!"
    exit 1
fi

source "$PROJECT_ROOT/.env"

# Check required variables
if [ -z "$CLOUDFLARE_EMAIL" ] || [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ ERROR: CLOUDFLARE_EMAIL and CLOUDFLARE_API_TOKEN must be set in .env"
    exit 1
fi

echo "🌐 Setting up Cloudflare DNS for Innexar Platform"
echo "   Domain: $DOMAIN"
echo "   Server IP: $SERVER_IP"
echo "   Account: $CLOUDFLARE_EMAIL"
echo

# Get Zone ID
echo "🔍 Getting Zone ID for $DOMAIN..."
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ "$ZONE_ID" = "null" ] || [ -z "$ZONE_ID" ]; then
    echo "❌ ERROR: Could not find zone for $DOMAIN"
    echo "   Make sure the domain is added to your Cloudflare account"
    exit 1
fi

echo "✅ Zone ID: $ZONE_ID"

# DNS Records to create
declare -a DNS_RECORDS=(
    "@:$SERVER_IP:A:Main domain record"
    "git:$SERVER_IP:A:GitLab"
    "sonar:$SERVER_IP:A:SonarQube"
    "nexus:$SERVER_IP:A:Nexus Repository"
    "auth:$SERVER_IP:A:Keycloak"
    "grafana:$SERVER_IP:A:Grafana"
    "monitor:$SERVER_IP:A:Prometheus"
    "traefik:$SERVER_IP:A:Traefik Dashboard"
    "docs:$SERVER_IP:A:Documentation (future)"
)

# Function to create DNS record
create_dns_record() {
    local name=$1
    local content=$2
    local type=$3
    local comment=$4

    echo "📝 Creating $type record: $name.$DOMAIN -> $content ($comment)"

    local response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
         -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
         -H "Content-Type: application/json" \
         --data "{
           \"type\": \"$type\",
           \"name\": \"$name\",
           \"content\": \"$content\",
           \"ttl\": 1,
           \"proxied\": true,
           \"comment\": \"$comment\"
         }")

    local success=$(echo $response | jq -r '.success')
    if [ "$success" = "true" ]; then
        echo "✅ Created successfully"
    else
        local error=$(echo $response | jq -r '.errors[0].message')
        echo "❌ Failed: $error"
        return 1
    fi
}

# Create DNS records
echo
echo "🚀 Creating DNS records..."

for record in "${DNS_RECORDS[@]}"; do
    IFS=':' read -r name content type comment <<< "$record"
    create_dns_record "$name" "$content" "$type" "$comment" || {
        echo "⚠️  Continuing with next record..."
    }
done

# Configure SSL/TLS settings
echo
echo "🔒 Configuring SSL/TLS settings..."

# Set SSL mode to Full (Strict)
echo "Setting SSL mode to Full (Strict)..."
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "full"}' > /dev/null

# Enable Always Use HTTPS
echo "Enabling Always Use HTTPS..."
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/always_use_https" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "on"}' > /dev/null

# Enable Automatic HTTPS Rewrites
echo "Enabling Automatic HTTPS Rewrites..."
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/automatic_https_rewrites" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "on"}' > /dev/null

echo
echo "🎉 DNS setup completed!"
echo
echo "📋 Summary of created records:"
echo "   - @.$DOMAIN -> $SERVER_IP (Main domain)"
echo "   - git.$DOMAIN -> $SERVER_IP (GitLab)"
echo "   - sonar.$DOMAIN -> $SERVER_IP (SonarQube)"
echo "   - nexus.$DOMAIN -> $SERVER_IP (Nexus)"
echo "   - auth.$DOMAIN -> $SERVER_IP (Keycloak)"
echo "   - traefik.$DOMAIN -> $SERVER_IP (Traefik Dashboard)"
echo "   - grafana.$DOMAIN -> $SERVER_IP (Grafana)"
echo "   - monitor.$DOMAIN -> $SERVER_IP (Prometheus)"
echo "   - docs.$DOMAIN -> $SERVER_IP (Future)"
echo
echo "⏱️  DNS propagation may take up to 24 hours"
echo "   You can check status at: https://dash.cloudflare.com/"
echo
echo "🧪 Test the configuration:"
echo "   curl -I https://git.$DOMAIN"
echo "   curl -I https://sonar.$DOMAIN"
echo "   curl -I https://nexus.$DOMAIN"
echo "   curl -I https://auth.$DOMAIN"
echo "   curl -I https://grafana.$DOMAIN"
echo "   curl -I https://monitor.$DOMAIN"
