#!/usr/bin/env bash
# Gera cert/key self-signed com SAN de IP para servir HTTPS no ingress-nginx do k3s de
# producao (192.168.2.123, acessado direto por IP na LAN, sem dominio/DNS). Nao usar em
# producao real com dominio publico (ali o caminho e Let's Encrypt via cert-manager, nao
# self-signed) — isto existe so porque o acesso hoje e por IP puro na rede local.
#
# Uso: ./generate-dev-cert.sh [IP]  (default: 192.168.2.123, o servidor k3s atual — ver
# docs/services/infra.md "Migracao pro k3s de producao")
set -euo pipefail
cd "$(dirname "$0")"

IP="${1:-192.168.2.123}"

openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
  -keyout dev-selfsigned.key -out dev-selfsigned.crt \
  -subj "/CN=${IP}" \
  -addext "subjectAltName=IP:${IP}"

echo "Gerado dev-selfsigned.{crt,key} para IP:${IP}. Proximo passo (kubectl apontando pro k3s):"
echo "  kubectl create secret tls web-tls-selfsigned --cert=dev-selfsigned.crt --key=dev-selfsigned.key --dry-run=client -o yaml | kubectl apply -f -"
