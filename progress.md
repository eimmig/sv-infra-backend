# Log de Progresso — infra

## Estado Atual (Current State)

**Última atualização:** 2026-08-02 00:00
**Feature ativa:** nenhuma

## Status

### O que está pronto

- [x] Harness deste repositório criado.

### Em andamento

- Nenhuma feature iniciada.

### Próximos passos (Next Steps)

1. `feat-001` — `docker-compose.yml` com PostgreSQL, RabbitMQ (DLQ), Redis, n8n.

## Bloqueios / Riscos

- `feat-002` (teste de resiliência) está bloqueada até `epic-004` (stats-service) e `epic-005`
  (telegram-integration) da raiz estarem `done` — dependência cross-repositório, não expressável
  no `dependencies` do `feature_list.json` deste harness.

## Decisões tomadas

- Harness criado nesta sessão para dar a `epic-001`/`epic-007` (sem serviço de aplicação
  próprio) um repositório real, já que a raiz não é (e não vai ser) um repositório Git — ver
  `../docs/DECISIONS-LOG.md` "Topologia: 6 repositórios independentes, não monorepo" (este é o
  7º).
- CI adaptada (sem i18n, sem SonarCloud) — este harness não tem texto de usuário nem código de
  aplicação para analisar. Ver `../docs/CI-CD.md`.

## Arquivos modificados nesta sessão

- `CLAUDE.md`, `feature_list.json`, `init.sh`, `progress.md`, `session-handoff.md`,
  `CHANGELOG.md`, `.github/workflows/ci.yml`, `.github/scripts/validate-changelog.sh` — criados.

## Evidência de conclusão

- Não aplicável ainda.

## Notas para a próxima sessão

Ver `../docs/services/infra.md` para os diagramas de resiliência (DLQ/retry) antes de começar
`feat-002`.
