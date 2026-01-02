#!/bin/bash

# DNS Status Check Script
# Run with: bash scripts/check-dns.sh

echo "🔍 Checking DNS propagation status for Innexar Platform"
echo "   Server IP: 66.93.25.253"
echo

DOMAINS=(
    "git.innexar.app"
    "sonar.innexar.app"
    "nexus.innexar.app"
    "auth.innexar.app"
    "grafana.innexar.app"
    "monitor.innexar.app"
    "traefik.innexar.app"
)

check_domain() {
    local domain=$1
    local expected_ip="66.93.25.253"

    echo -n "   $domain: "

    # Try multiple DNS servers for better accuracy
    local ip=$(dig +short $domain @8.8.8.8 2>/dev/null | head -n1)

    if [ -z "$ip" ]; then
        echo "❌ No response"
    elif [ "$ip" = "$expected_ip" ]; then
        echo "✅ $ip (Correct!)"
    else
        echo "⚠️  $ip (Different IP - still propagating?)"
    fi
}

echo "🌐 DNS Resolution Status:"
for domain in "${DOMAINS[@]}"; do
    check_domain "$domain"
done

echo
echo "🔒 HTTPS Certificate Status:"
for domain in "${DOMAINS[@]}"; do
    echo -n "   $domain: "
    if curl -s --max-time 5 -k "https://$domain" > /dev/null 2>&1; then
        echo "✅ Certificate active"
    else
        echo "⏳ Certificate pending or DNS not ready"
    fi
done

echo
echo "💡 Tips:"
echo "   - DNS propagation can take up to 24 hours"
echo "   - Run this script multiple times to check progress"
echo "   - If DNS is ready but HTTPS fails, check Cloudflare SSL settings"
echo "   - Make sure SSL mode is set to 'Full (Strict)' in Cloudflare"
