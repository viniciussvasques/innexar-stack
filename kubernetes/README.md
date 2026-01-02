# Kubernetes Setup - Plataforma Innexar

## Pré-requisitos

- Cluster Kubernetes (mínimo 3 nodes recomendado)
- kubectl configurado
- StorageClass configurado no cluster
- Pelo menos 32GB RAM total no cluster
- 200GB+ storage disponível

## Deploy

```bash
# 1. Criar namespace
kubectl apply -f namespace.yaml

# 2. Deploy Secrets (senhas e configurações)
kubectl apply -f secrets.yaml

# 3. Deploy databases
kubectl apply -f postgres-sonarqube.yaml
kubectl apply -f postgres-keycloak.yaml

# 4. Deploy serviços
kubectl apply -f sonarqube.yaml
kubectl apply -f keycloak.yaml
kubectl apply -f nexus.yaml
kubectl apply -f gitlab.yaml

# 5. Deploy Traefik
kubectl apply -f traefik-ingress.yaml

# 6. Deploy Ingress
kubectl apply -f ingress.yaml

# 7. Deploy Monitoramento
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml

# 8. Deploy Backup (opcional)
kubectl apply -f backup-cronjob.yaml
```

## Verificar Status

```bash
kubectl get pods -n innexar-platform
kubectl get svc -n innexar-platform
kubectl get ingress -n innexar-platform
```

## URLs de Acesso

- GitLab: https://git.innexar.app
- SonarQube: https://sonar.innexar.app
- Nexus: https://nexus.innexar.app
- Keycloak: https://auth.innexar.app
- Grafana: https://grafana.innexar.app (admin / Admin@Grafana2025!)
- Prometheus: https://monitor.innexar.app

## Backup

```bash
# Backup PVCs (executar em cada node)
kubectl get pvc -n innexar-platform
# Fazer backup manual dos volumes ou usar Velero
```

## Atualizar Secrets sem recriar pods

```bash
kubectl delete secret <secret-name> -n innexar-platform
kubectl apply -f <secret-file>.yaml
kubectl rollout restart deployment/<deployment-name> -n innexar-platform
```

