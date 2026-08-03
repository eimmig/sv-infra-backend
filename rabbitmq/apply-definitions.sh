#!/bin/sh
# Aplica rabbitmq/definitions.json (exchanges, filas e bindings) pela API de
# gerenciamento, depois que o broker ja esta healthy.
#
# Por que nao usar `load_definitions` no rabbitmq.conf: a documentacao oficial do
# RabbitMQ diz que "if a blank (uninitialised) node imports a definition file, it
# will not create the default virtual host and user" — o broker subiria sem vhost
# e sem usuario, e o healthcheck ainda assim passaria (o no esta rodando), uma
# falha silenciosa. Importando depois do boot, o usuario default continua sendo
# criado a partir de RABBITMQ_DEFAULT_USER/PASS e nenhum segredo precisa ser
# versionado dentro do definitions.json.
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
