#!/usr/bin/env bash
# Sobe o tunel publico do n8n (webhook do Telegram): port-forward do n8n + ngrok com dominio fixo.
# O WEBHOOK_URL do deployment n8n precisa apontar para o mesmo dominio.
#
# Uso (no servidor k3s): ./scripts/subir-tunel.sh
# Configuracao: NGROK_DOMAIN no ambiente ou no arquivo ~/.sv-tunel.env (fora do Git), ex.:
#   NGROK_DOMAIN=meu-dominio.ngrok-free.dev
set -u
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
ENV_FILE="${ENV_FILE:-$HOME/.sv-tunel.env}"
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && . "$ENV_FILE"
if [ -z "${NGROK_DOMAIN:-}" ]; then
  echo "Defina NGROK_DOMAIN no ambiente ou em $ENV_FILE." >&2
  exit 2
fi

echo "Encerrando tunel antigo, se houver..."
# O kubectl do k3s reescreve a linha de comando (aparece so "kubectl"), entao o port-forward
# antigo e achado pelo processo que escuta a porta 5678, nao pelo nome.
pid_antigo=$(ss -ltnpH "sport = :5678" 2>/dev/null | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)
[ -n "$pid_antigo" ] && kill "$pid_antigo" 2>/dev/null
pkill -f "ngrok http" 2>/dev/null
sleep 1

echo "Subindo port-forward do n8n (5678)..."
nohup kubectl port-forward svc/n8n 5678:5678 > "$HOME/pf-n8n.log" 2>&1 &
sleep 3

echo "Subindo ngrok em https://$NGROK_DOMAIN ..."
nohup ngrok http --url="$NGROK_DOMAIN" 5678 --log=stdout > "$HOME/ngrok.log" 2>&1 &

codigo=000
for _ in $(seq 1 15); do
  sleep 2
  codigo=$(curl -s -o /dev/null -w "%{http_code}" "https://$NGROK_DOMAIN/healthz")
  if [ "$codigo" = "200" ]; then
    echo "OK  tunel no ar: https://$NGROK_DOMAIN/healthz respondeu 200"
    exit 0
  fi
done
echo "FALHA  o tunel nao respondeu 200 (ultimo codigo: $codigo)."
echo "Veja: tail -20 ~/ngrok.log   e   tail -5 ~/pf-n8n.log"
exit 1
