#!/usr/bin/env bash
# Uso: ./generate-dev-cert.sh [IP]  (default: 192.168.2.123, o servidor k3s atual — ver
set -euo pipefail
cd "$(dirname "$0")"

IP="${1:-192.168.2.123}"

openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
  -keyout dev-selfsigned.key -out dev-selfsigned.crt \
  -subj "/CN=${IP}" \
  -addext "subjectAltName=IP:${IP}"

echo "Gerado dev-selfsigned.{crt,key} para IP:${IP}. Proximo passo (kubectl apontando pro k3s):"
echo "  kubectl create secret tls web-tls-selfsigned --cert=dev-selfsigned.crt --key=dev-selfsigned.key --dry-run=client -o yaml | kubectl apply -f -"
