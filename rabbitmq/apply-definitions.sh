#!/bin/sh
set -eu

: "${RABBITMQ_USER:?RABBITMQ_USER nao definido — copie .env.example para .env}"
: "${RABBITMQ_PASSWORD:?RABBITMQ_PASSWORD nao definido — copie .env.example para .env}"

echo "Aplicando definicoes de topologia no RabbitMQ..."

curl --silent --show-error --fail-with-body \
  --user "${RABBITMQ_USER}:${RABBITMQ_PASSWORD}" \
  --header 'Content-Type: application/json' \
  --request POST \
  --data-binary @/definitions.json \
  http://rabbitmq:15672/api/definitions

echo "Topologia aplicada: exchanges bets.events / bets.events.dlx, filas stats.bet-events / stats.bet-events.dlq."
