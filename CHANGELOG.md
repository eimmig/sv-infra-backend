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
- `feature_list.json` ganhou os campos `jira` (chave da story, que também nomeia a branch de
  trabalho) e `subtasks` (passos de implementação vindos do `Plan Reviewer`, cada um com `id`,
  `name`, `status` e `jira`) por feature. `feat-001` foi retro-preenchida com as 8 subtasks que
  a implementação de fato teve; os campos `jira` ficam vazios porque a story foi entregue antes
  da decisão de espelhar o backlog no Jira. Ver `CLAUDE.md` da raiz, seção "Regras de trabalho".
- Bootstrap dos 6 repositórios de aplicação (`feat-003`): commit inicial em `main` e branch
  `develop` publicados em `sv-api-gateway`, `sv-auth-backend`, `sv-bets-backend`,
  `sv-stats-backend`, `sv-telegram-integration-backend` e `sv-frontend`. Só harness, sem código
  de aplicação. `init.sh` e `.github/scripts/validate-changelog.sh` versionados como `100755` nos
  7 repositórios — o `CLAUDE.md` manda rodar `./init.sh`, que falharia num clone Linux com o bit
  ausente.
- Verificado que a guarda por arquivo-marcador funciona no GitHub: nos 12 pushes (6 × `main`,
  6 × `develop`) a pipeline ficou verde, com `checkout` executado e todos os passos seguintes
  `skipped`. Sem a guarda, o `actions/setup-node` com `cache: npm` teria falhado por ausência de
  lockfile.
- Chave de projeto do SonarCloud alinhada ao formato que a ferramenta gera ao importar do GitHub
  (`eimmig_<repo>`) nos 6 repositórios de aplicação — `feat-003.8`, descoberta durante a
  implementação e acrescentada ao backlog em vez de virar trabalho invisível.
- Guarda por arquivo-marcador (`hashFiles`) nos 6 `ci.yml` dos repositórios de aplicação e
  `.gitignore`/`.gitattributes` por stack nos mesmos 6 — preparados aqui (`feat-003`), aplicados
  no commit inicial de cada um. Sem a guarda, um repositório só com harness ficaria com CI
  vermelha desde o primeiro push, porque `actions/setup-node` com `cache: npm` **falha** o job sem
  lockfile e `mvn package`/`npm ci`/`uv sync` não têm projeto para construir.
- `.github/workflows/ci.yml`: comentário explicitando que a validação do `CHANGELOG.md` roda em
  **todo** PR, inclusive nos de subtask → branch da story, cujas linhas se acumulam em
  `[Unreleased]` até o merge em `develop`.

### Fixed

- `.github/scripts/validate-changelog.sh` passou a ser versionado como `100755` (bit de execução).
  Estava como `100644` desde o commit inicial — o `run:` do workflow o invoca direto, então o
  primeiro PR deste repositório teria falhado com *Permission denied*. Passou despercebido porque
  o passo só roda em `pull_request` e todos os commits até aqui foram diretos em `develop`.
  Encontrado pelo `Plan Reviewer` de `feat-003` (`SV-2`), antes de o mesmo defeito ser propagado
  para os outros 6 repositórios.
- `feat-002` não cita mais **RNF06 (Escalabilidade)** como justificativa do teste de resiliência.
  Conferido no PDF do TCC 1 em 2026-08-17: a tabela original tem 6 RNFs e nenhum é sobre
  tolerância a falha — RNF06 é volume. A base do teste no TCC 1 é a prosa da seção 4.1 (p. 30) e
  do capítulo de arquitetura, que especificam *retries* + DLQ sem atribuir ID ao requisito.
  Nenhum RNF novo foi criado. Ver `docs/REQUIREMENTS.md` e `docs/DECISIONS-LOG.md` no vault.
