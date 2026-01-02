# Innexar Platform (Unified)

Complete DevOps stack with Single Sign-On (Keycloak), running on Docker Compose.

## Services
- **GitLab**: Source Code & Dependency Management (Docker/Maven Registry).
- **SonarQube**: Code Quality & Security.
- **Keycloak**: Central Authentication (SSO).
- **Traefik**: Reverse Proxy & SSL.
- **Monitoring**: Prometheus, Grafana, Uptime Kuma.
- **Portainer**: Docker Management UI.

## Quick Start

1. **Configure**: Check `.env` and set secure passwords.
2. **DNS**: Ensure your domain (`innexar.app`) or `hosts` file points to `127.0.0.1`.
3. **Run**:
   ```bash
   docker compose up -d
   ```
4. **Access**:
   - Status: https://status.innexar.app
   - Auth: https://auth.innexar.app
   - Git: https://git.innexar.app
   - Sonar: https://sonar.innexar.app
   - Grafana: https://grafana.innexar.app
   - Portainer: https://portainer.innexar.app

## Credentials
Check `.env` for default passwords.
- **GitLab Root**: Get via `docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password` (valid for 24h).
