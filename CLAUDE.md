# CLAUDE.md — infra

Docker Compose local para os serviços de infraestrutura compartilhada (PostgreSQL, RabbitMQ,
Redis, n8n) e o teste de resiliência cross-service (DLQ/retry). Parte do harness multinível do
projeto — leia `../CLAUDE.md` (raiz) para invariantes cross-service antes deste arquivo, e
`../docs/services/infra.md` para o desenho completo (componentes, diagramas de resiliência).
**Este é seu próprio repositório Git**, não um monorepo — ver `../docs/DECISIONS-LOG.md`
"Topologia".

## Por que este harness existe

`epic-001` e `epic-007` da raiz não pertencem a nenhum serviço de aplicação (não têm domínio de
negócio, não são Java/Python/Angular) — mas também não podem viver na raiz, que não é um
repositório. Este harness (e o repositório que nasce dele) existe para dar a esses dois epics um
lugar real para código/config versionados, seguindo o mesmo padrão dos outros 6 repositórios.

## Fluxo de início de sessão (Startup Workflow)

1. Confirme o diretório de trabalho (`pwd`) — deve ser `infra`.
2. Leia `../CLAUDE.md` e `../docs/services/infra.md`.
3. Rode `./init.sh` para verificar a validade do `docker-compose.yml`.
4. Leia `feature_list.json` (deste harness) para a próxima feature granular.
5. Leia `progress.md` (deste harness).

## Regras específicas deste harness

- **Uma feature por vez (One feature at a time)**: escolha exatamente uma feature `not-started`
  de `feature_list.json` cujas dependências já estejam `done`.
- **Escopo restrito (stay in scope)**: não edite código de nenhum serviço de aplicação a partir
  desta pasta — este harness só cobre orquestração local (Docker Compose) e o teste de
  resiliência cross-service, nunca lógica de negócio.
- **`feat-001` (Docker Compose)**: **entregue em 2026-08-03**. Três containers PostgreSQL
  (`postgres-auth` 5432, `postgres-bets` 5433, `postgres-stats` 5434 — Database per Service,
  ver `../docs/DECISIONS-LOG.md` 2026-08-03), RabbitMQ 4 com **DLQ configurada desde o início**
  (não como melhoria futura), Redis com senha obrigatória (uso exclusivo de `stats-service`),
  n8n (webhook do Telegram, não depende de nenhum outro container). Healthcheck em todos —
  sempre em `CMD-SHELL` quando o comando usa variável de ambiente, porque exec form não expande
  `$$VAR`. Ver `../docs/services/infra.md` e `../docs/OBSERVABILITY-AND-CONFIG.md`.
- **Topologia do RabbitMQ é contrato, não configuração local**: exchanges/filas/bindings vivem em
  `rabbitmq/definitions.json` e estão documentados em `../docs/API-CONTRACTS.md` seção "Topologia
  RabbitMQ" — `bets-service` e `stats-service` consomem/publicam **sem redeclarar**. Mudar um
  nome ou argumento aqui é mudança de contrato e atualiza aquela nota no mesmo commit.
- **A topologia é aplicada pós-boot, não por `load_definitions`**: o container one-shot
  `rabbitmq-init` roda `rabbitmq/apply-definitions.sh` depois do broker ficar `healthy`. Não
  troque isso por `load_definitions` no `rabbitmq.conf`: um nó novo que importa definições **não
  cria o vhost `/` nem o usuário default**, e o healthcheck continua passando — falha silenciosa.
  Racional completo em `../docs/DECISIONS-LOG.md` (2026-08-03).
- **`feat-002` (teste de resiliência)**: **bloqueada até `epic-004` (stats-service) e
  `epic-005` (telegram-integration) da raiz estarem `done`** — dependência cross-repositório, não
  expressável no `dependencies` deste `feature_list.json`. Confira o `feature_list.json` da raiz
  antes de iniciar. Teste de aceite: derrubar `stats-service`, publicar eventos via
  `bets-service`, subir `stats-service` de novo, confirmar reprocessamento sem perda — ver
  `../docs/services/infra.md` seção "Resiliência" para os diagramas esperados.
- **Sem arquitetura hexagonal, sem i18n**: este harness não tem código de aplicação nem texto
  voltado ao usuário final — as convenções de `../docs/CONVENTIONS.md` sobre estrutura
  `domain/`/`application/`/`adapter/` e internacionalização não se aplicam aqui.
- **CI/CD**: pipeline em `.github/workflows/ci.yml`, adaptada — sem passo de i18n (não há
  texto de usuário) nem SonarCloud (não há código de aplicação para analisar): só changelog e
  validação de `docker compose config`. Ver `../docs/CI-CD.md`.
- **Skills de agente prioritárias**: `Plan Reviewer` antes de codificar; `Architecture Diagram
  Builder`/`Current Architecture Documenter` para conferir a topologia do compose contra
  `../docs/ARCHITECTURE.md` (nunca gerar diagrama paralelo); `Acceptance Test Builder` para
  `feat-002` (teste de resiliência); `Delivery Reviewer` antes de marcar `done`
  (claude-code-skills) — mapeamento completo em `../docs/AGENT-SKILLS.md`. Instaladas em
  2026-08-02 (escopo `user`), ver `../docs/DECISIONS-LOG.md`.

## Definição de pronto (Definition of Done)

Uma feature deste harness só está `done` quando (done only when):

- [ ] Implementada e rodando via `./init.sh` sem erro (`docker compose config` válido).
- [ ] Para `feat-001`: `docker compose up` sobe com todos os healthchecks passando.
- [ ] Para `feat-002`: teste de resiliência documentado em `../docs/services/infra.md` executado
      com sucesso.
- [ ] `Delivery Reviewer` rodado contra a feature (ver `../docs/AGENT-SKILLS.md`).
- [ ] `CHANGELOG.md` deste harness tem uma entrada em `[Unreleased]` descrevendo a mudança.
- [ ] `feature_list.json` atualizado com status e evidência.
- [ ] `../feature_list.json` (raiz) atualizado — `evidence` do epic correspondente
      (`epic-001` para `feat-001`, `epic-007` para `feat-002`).

## Fim de sessão (End of Session)

Antes de encerrar (before ending a session): atualize `progress.md` deste harness, atualize
`feature_list.json`, e deixe `./init.sh` passando (clean, restartable state).

## Verificação

```bash
cp .env.example .env       # uma vez; o .env real nunca e versionado
./init.sh                  # valida o docker-compose.yml (docker compose config)

docker compose up -d
docker compose ps          # os 6 containers de longa duracao devem estar (healthy)
docker compose logs rabbitmq-init   # confirma que a topologia foi aplicada
docker compose down -v     # estado limpo para a proxima sessao
```

`rabbitmq-init` é um container one-shot: `docker compose up -d` **não** espera por ele nem falha
se ele falhar. Sempre confira o log dele — sem a topologia aplicada, o broker sobe vazio e o
problema só apareceria no `epic-003`.
