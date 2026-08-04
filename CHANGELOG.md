# Changelog

Todas as mudanças notáveis deste repositório são documentadas neste arquivo. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Toda feature que altera este
repositório adiciona uma entrada em `[Unreleased]` — verificado automaticamente pela pipeline de
CI (ver `docs/CI-CD.md`).

## [Unreleased]

### Added

- `docker-compose.yml` com a infraestrutura local completa (`feat-001`, fecha `epic-001` da
  raiz): três instâncias PostgreSQL (`postgres-auth` 5432, `postgres-bets` 5433,
  `postgres-stats` 5434 — Database per Service), RabbitMQ 4 com console de gerenciamento
  (5672/15672), Redis com autenticação obrigatória (6379) e n8n (5678). Healthcheck em todos.
- Topologia RabbitMQ versionada em `rabbitmq/definitions.json`: exchange `bets.events` (topic),
  fila `stats.bet-events` (quorum, `x-delivery-limit: 3`, dead-letter para `bets.events.dlx`),
  exchange `bets.events.dlx` (fanout) e fila `stats.bet-events.dlq` — DLQ configurada desde o
  início, não como melhoria futura. Contrato completo em `docs/API-CONTRACTS.md`.
- `rabbitmq/apply-definitions.sh` e o container one-shot `rabbitmq-init`, que aplicam a
  topologia pela API de gerenciamento depois do broker ficar `healthy` (`load_definitions`
  impediria a criação do vhost e do usuário default).
- `.env.example` com todas as variáveis necessárias e `.gitignore` cobrindo o `.env` real.
- `.gitattributes` fixando LF em `.sh`/`.yml`/`.json`, para checkout Windows não gerar CRLF que
  quebra em runner Linux.

### Changed

- `feature_list.json` ganhou o campo `plan_review` por feature, pré-requisito para marcar uma
  feature como `in-progress` (mesmo papel que `evidence` tem para `done`). Mudança aplicada aos
  7 harnesses do projeto — ver `CLAUDE.md` da raiz, seção "Regras de trabalho".
