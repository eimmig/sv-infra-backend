#!/usr/bin/env bash
# Checkup do servidor k3s de producao. Somente leitura: nao muda nada no cluster.
# Uso (no servidor): ./scripts/checkup.sh
# Opcional, para conferir o webhook no Telegram: TELEGRAM_BOT_TOKEN=... ./scripts/checkup.sh
# Dominio do tunel do n8n: NGROK_DOMAIN no ambiente ou em ~/.sv-tunel.env (fora do Git).
set -u
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
ENV_FILE="${ENV_FILE:-$HOME/.sv-tunel.env}"
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && . "$ENV_FILE"
DOMINIO="${NGROK_DOMAIN:-}"
falhas=0; avisos=0
ok()    { printf "  \033[32mOK\033[0m     %s\n" "$1"; }
aviso() { printf "  \033[33mATENCAO\033[0m %s\n" "$1"; avisos=$((avisos+1)); }
falha() { printf "  \033[31mFALHA\033[0m  %s\n" "$1"; falhas=$((falhas+1)); }
titulo(){ printf "\n\033[1m%s\033[0m\n" "$1"; }

titulo "1. Rede"
ip_atual=$(hostname -I | awk '{print $1}')
echo "  IP do notebook: $ip_atual"
c=$(curl -s -o /dev/null -m 8 -w "%{http_code}" https://api.telegram.org)
[ "$c" != "000" ] && ok "internet (api.telegram.org respondeu $c)" || falha "sem internet: conecte em outra rede (hotspot do celular)"

titulo "2. Kubernetes (k3s)"
systemctl is-active --quiet k3s && ok "servico k3s ativo" || falha "k3s parado: sudo systemctl start k3s"
linha=$(kubectl get node --no-headers -o wide 2>/dev/null)
if [ -z "$linha" ]; then
  falha "kubectl nao responde (k3s ainda subindo? espere 1 min e rode de novo)"
else
  estado=$(echo "$linha" | awk '{print $2}'); ip_no=$(echo "$linha" | awk '{print $6}')
  [ "$estado" = "Ready" ] && ok "no Ready" || falha "no em estado $estado"
  if echo " $(hostname -I) " | grep -q " $ip_no "; then ok "IP do no ($ip_no) e o IP atual"
  else falha "no preso no IP antigo ($ip_no): sudo systemctl restart k3s, espere 2 min e rode de novo"; fi
fi
kubectl top node --no-headers >/dev/null 2>&1 && ok "metrics-server responde (HPA funcionando)" \
  || aviso "kubectl top node falhou: metrics-server ainda subindo ou no com IP antigo"

titulo "3. Pods"
nao_prontos=$(kubectl get pods -A --no-headers 2>/dev/null | awk '{split($3,a,"/"); if (a[1]!=a[2] && $4!="Completed") print $1"/"$2" ("$4")"}')
total=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
if [ -z "$nao_prontos" ]; then ok "todos os $total pods prontos"
else falha "pods nao prontos:"; echo "$nao_prontos" | sed 's/^/           /'; fi
for d in api-gateway auth-service bets-service stats-service telegram-integration web n8n rabbitmq redis postgres-auth postgres-bets postgres-stats; do
  pronto=$(kubectl get deploy "$d" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  [ -n "$pronto" ] && [ "$pronto" -ge 1 ] && ok "$d ($pronto pronta)" || falha "$d sem replica pronta"
done

titulo "4. Acesso web e API"
c=$(curl -sk -o /dev/null -m 8 -w "%{http_code}" https://localhost/)
[ "$c" = "200" ] && ok "web em https://localhost (200)" || falha "web respondeu $c"
c=$(curl -sk -o /dev/null -m 8 -w "%{http_code}" https://localhost/api/v1/bets)
[ "$c" = "401" ] && ok "API Gateway responde (401 sem token, esperado)" || falha "API Gateway respondeu $c (esperado 401)"

titulo "5. Bancos, mensageria e cache"
for db in postgres-auth postgres-bets postgres-stats; do
  kubectl exec deploy/$db -- pg_isready -q >/dev/null 2>&1 && ok "$db aceita conexoes" || falha "$db nao responde"
done
kubectl exec deploy/redis -- sh -c 'redis-cli --no-auth-warning -a "$REDIS_PASSWORD" ping' 2>/dev/null | grep -q PONG \
  && ok "redis responde PONG" || falha "redis nao responde"
filas=$(kubectl exec deploy/rabbitmq -- rabbitmqctl -q list_queues name messages consumers 2>/dev/null)
if echo "$filas" | grep -q "^stats.bet-events[[:space:]]"; then
  consumidores=$(echo "$filas" | awk '$1=="stats.bet-events"{print $3}')
  [ "${consumidores:-0}" -ge 1 ] && ok "fila stats.bet-events com $consumidores consumidor(es)" \
    || falha "fila stats.bet-events sem consumidor: kubectl rollout restart deploy/stats-service"
  dlq=$(echo "$filas" | awk '$1=="stats.bet-events.dlq"{print $2}')
  [ "${dlq:-0}" -eq 0 ] && ok "DLQ vazia" || aviso "DLQ com $dlq mensagem(ns)"
else
  falha "fila stats.bet-events nao existe: kubectl delete job rabbitmq-init; kubectl apply -f k8s/rabbitmq.yaml"
fi

titulo "6. Telegram (tunel do n8n)"
pgrep -f "port-forward svc/n8n" >/dev/null && ok "port-forward do n8n rodando" || falha "port-forward do n8n parado: ./subir-tunel.sh"
pgrep -f "ngrok http" >/dev/null && ok "ngrok rodando" || falha "ngrok parado: ./subir-tunel.sh"
if [ -z "$DOMINIO" ]; then
  aviso "NGROK_DOMAIN nao definido (ambiente ou $ENV_FILE): tunel e webhook nao conferidos"
else
  c=$(curl -s -o /dev/null -m 10 -w "%{http_code}" "https://$DOMINIO/healthz")
  [ "$c" = "200" ] && ok "n8n acessivel pela internet (https://$DOMINIO)" || falha "tunel respondeu $c: ./subir-tunel.sh"
fi
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "$DOMINIO" ]; then
  info=$(curl -s -m 10 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo")
  echo "$info" | grep -q "$DOMINIO" && ok "webhook do Telegram aponta para o tunel" || falha "webhook do Telegram nao aponta para $DOMINIO"
  pend=$(echo "$info" | grep -o '"pending_update_count":[0-9]*' | cut -d: -f2)
  erro=$(echo "$info" | grep -o '"last_error_message":"[^"]*"' | cut -d'"' -f4)
  [ "${pend:-0}" -eq 0 ] && ok "nenhuma mensagem presa no Telegram" || aviso "$pend mensagem(ns) aguardando entrega"
  [ -n "$erro" ] && aviso "ultimo erro do webhook: $erro (pode ser antigo)"
else
  echo "  (para conferir o webhook no Telegram: TELEGRAM_BOT_TOKEN=<token> ./checkup.sh)"
fi

titulo "Resumo"
if [ "$falhas" -eq 0 ]; then
  printf "  \033[32mTudo certo\033[0m (%s aviso(s)). Falta o teste manual: login, registrar aposta e mandar mensagem ao bot.\n" "$avisos"
else
  printf "  \033[31m%s falha(s)\033[0m e %s aviso(s). Corrija pela ordem e rode de novo.\n" "$falhas" "$avisos"
fi
exit "$falhas"
