# Log de Progresso — infra

## Estado Atual (Current State)

**Última atualização:** 2026-09-10
**Feature ativa:** nenhuma (`feat-001`/`feat-002`/`feat-003` `done`; `feat-004` `not-started`,
sem `plan_review`)

## Status

### O que está pronto

- [x] Harness deste repositório criado (2026-08-02).
- [x] Primeiro commit e branches `main`/`develop` publicados em
      `github.com/eimmig/sv-infra-backend` (2026-08-03).
- [x] `feat-001` — `docker-compose.yml` com Postgres (3 containers), RabbitMQ 4 com DLQ, Redis e
      n8n. Fecha `epic-001` da raiz.

### Em andamento

- Nenhuma feature iniciada.

### Próximos passos (Next Steps)

1. Nada neste repositório até `epic-004`/`epic-005` fecharem — `feat-002` depende deles.
2. O caminho crítico agora é `epic-002` (`auth-service`), que só dependia de `epic-001`.

## Bloqueios / Riscos

- `feat-002` (teste de resiliência) continua bloqueada até `epic-004` (stats-service) e
  `epic-005` (telegram-integration) da raiz estarem `done` — dependência cross-repositório, não
  expressável no `dependencies` do `feature_list.json` deste harness.
- **DLQ usa a estratégia default `at-most-once`**: em falha de broker a mensagem pode se perder
  no trajeto até a DLQ. Tradeoff aceito conscientemente (ver `../docs/DECISIONS-LOG.md`
  2026-08-03) — `at-least-once` exigiria `overflow: reject-publish`, que muda comportamento
  visível de `bets-service`. **Reavaliar quando `feat-002` rodar**: se o teste de resiliência
  mostrar perda real de mensagem, esta decisão precisa ser revista.
- `rabbitmq-init` é one-shot e `docker compose up -d` não falha se ele falhar. Sempre conferir
  `docker compose logs rabbitmq-init` — sem topologia aplicada, o problema só apareceria no
  `epic-003`.

## Decisões tomadas

- Harness criado em 2026-08-02 para dar a `epic-001`/`epic-007` (sem serviço de aplicação
  próprio) um repositório real, já que a raiz não é (e não vai ser) um repositório Git — ver
  `../docs/DECISIONS-LOG.md` "Topologia".
- CI adaptada (sem i18n, sem SonarCloud) — este harness não tem texto de usuário nem código de
  aplicação para analisar. Ver `../docs/CI-CD.md`.
- **2026-08-03, quatro decisões de `feat-001`** (detalhe completo em `../docs/DECISIONS-LOG.md`,
  entrada 2026-08-03):
  1. **Três containers Postgres separados**, não três bancos num container só — escolha do
     usuário, resolvendo uma contradição entre `ARCHITECTURE.md`/`services/infra.md` ("instância
     lógica") e `DATA-MODEL.md` ("instâncias Postgres distintas"). As duas notas foram
     corrigidas no mesmo commit.
  2. **Topologia RabbitMQ nomeada e promovida a contrato** em `../docs/API-CONTRACTS.md` —
     `x-delivery-limit` só existe em quorum queue, e uma redeclaração divergente por
     `bets-service`/`stats-service` derrubaria o canal com `PRECONDITION_FAILED` em loop.
  3. **Definições aplicadas pós-boot** por `rabbitmq-init`, não por `load_definitions` — um nó
     novo que importa definições não cria o vhost `/` nem o usuário default, e o healthcheck
     ainda passa. Encontrado pelo `Plan Reviewer` **antes** de escrever qualquer código.
  4. **DLQ `at-most-once`** (default) no ambiente local — tradeoff explícito, ver Bloqueios.

## Arquivos modificados nesta sessão

Criados: `docker-compose.yml`, `.env.example`, `.gitignore`, `.gitattributes`,
`rabbitmq/definitions.json`, `rabbitmq/apply-definitions.sh`.
Alterados: `CLAUDE.md` (descrição de `feat-001` atualizada, regras sobre topologia-como-contrato
e sobre não trocar por `load_definitions`, bloco de verificação), `CHANGELOG.md`,
`feature_list.json`, `progress.md`.

No vault (raiz, fora deste repositório): `docs/DECISIONS-LOG.md`, `docs/API-CONTRACTS.md`,
`docs/ARCHITECTURE.md`, `docs/services/infra.md`.

## Evidência de conclusão

`feat-001` — ver campo `evidence` em `feature_list.json` para o detalhe completo. Resumo:
`./init.sh` passou; `docker compose up -d` subiu os 6 containers de longa duração `(healthy)`;
`rabbitmqctl list_queues/list_exchanges/list_bindings` confirmou a topologia exata (quorum,
`x-delivery-limit: 3`, DLX, routing keys `bet.created`/`bet.settled`); `psql` confirmou os três
bancos isolados; `redis-cli` sem senha retornou `NOAUTH`; `docker compose config` passa sem
`.env` (gate de CI); stack derrubada com `docker compose down -v`.

## Notas para a próxima sessão

Este repositório está em estado limpo e não tem trabalho pendente. Antes de começar `feat-002`,
leia `../docs/services/infra.md` seção "Resiliência" (diagramas de retry e DLQ) e confirme no
`feature_list.json` da raiz que `epic-004` e `epic-005` estão `done`.

Para subir a infra localmente: `cp .env.example .env` e seguir o bloco "Verificação" do
`CLAUDE.md` deste repositório.

## `feat-002` fechada — teste de resiliência cross-service, fecha `epic-007` da raiz (2026-09-10)

Sessão retomou `epic-007` (já `in-progress` desde a sessão anterior, que tinha deixado
`feat-002.1..3` prontas mas nunca empurradas pro GitHub). Executado nesta sessão:

- **`feat-002.4` (cenário DLQ)**: infra + 4 serviços Java subidos localmente (gotcha documentado
  em `docs/OBSERVABILITY-AND-CONFIG.md`: `mvnw spring-boot:run` exige `export` manual das
  variáveis do `.env` + `SPRING_PROFILES_ACTIVE=dev`, não lê `.env` sozinho). Tenant de teste novo
  (`feat002dlq`, criado por não ter a senha do tenant anterior `feat002test` registrada em nenhum
  artefato). `postgres-stats` parado, 1 evento publicado, poll na Management API do RabbitMQ até a
  mensagem cair em `stats.bet-events.dlq` (~105s, 3 tentativas de retry de aplicação limitadas
  pelo `connection-timeout` de 30s do HikariCP). Registro síncrono da aposta não bloqueou.
- **2 achados reais corrigidos ao longo do caminho, ambos fora deste repositório**:
  1. RabbitMQ 4.3+ deixou de contar `nack(requeue=true)` para `x-delivery-limit` — descoberto
     numa tentativa anterior desta mesma feature (sessão passada), corrigido em
     `services/stats-service feat-010` (retry de aplicação), fechado nesta sessão.
  2. `api-gateway` nunca roteava `/api/v1/tipsters/**` — decisão deliberada de `feat-007` daquele
     serviço que ficou obsoleta quando `apps/web feat-008` (catálogos) ganhou a aba de tipsters
     sem que ninguém revisitasse o roteamento. Encontrado montando o catálogo de teste (criar um
     tipster via Gateway devolvia 404). Corrigido em `services/api-gateway feat-008`.
- **`feat-002.5` (evidência e fechamento)**: Delivery Reviewer (passe próprio) sobre o texto de
  evidência antes de commitar — encontrou e corrigiu 2 imprecisões (uma alegação de "health 200 o
  tempo todo" que na verdade só foi verificada em 2 pontos, e atribuição errada de qual subtask
  provisionou o tenant original). Estratégia `at-most-once` da DLQ reconfirmada válida (nenhum dos
  2 cenários mostrou perda de mensagem).
- **Achado de processo, corrigido**: `feat-002.1..3` tinham sido mescladas localmente (git merge
  direto) sem nunca passar por PR/CI real do GitHub, desviando do fluxo de 2 gates deste
  `CLAUDE.md`. Corrigido nesta sessão: todas as branches empurradas pro GitHub e o PR
  `feature/SV-261 -> develop` (o gate mais pesado) passou pela CI real antes do merge — desvio
  documentado na descrição do PR e na evidência da feature, não escondido.
- Branches `feature/SV-261` e `subtask/SV-263..267` deletadas (local e remoto) após o merge. Numa
  limpeza mais ampla pedida pelo usuário, também deletadas dezenas de branches antigas já
  mescladas de sessões anteriores neste e nos outros repositórios tocados (`api-gateway`,
  `auth-service`, `bets-service`, `stats-service`, `telegram-integration`).

Ambiente encerrado: 4 processos Java parados, `docker compose down -v`, `./init.sh` da raiz e
deste repositório verdes.
