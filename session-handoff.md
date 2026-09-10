# Session Handoff — infra

> Estado atual, não histórico. O diário cronológico é o `progress.md` — este arquivo é reescrito
> a cada sessão para responder "o que a próxima sessão precisa saber agora".

**Última atualização:** 2026-09-10

## Objetivo atual

- `feat-001` e `feat-002` `done` — `epic-001` e `epic-007` da raiz fecham com isso.
- `feat-003` (bootstrap dos 7 repositórios + SonarCloud) `done`.
- `feat-004` (migração para Kubernetes, fecha `epic-010` da raiz) — único item `not-started`,
  sem `plan_review` ainda. Não bloqueia nada além de si mesmo.

## Concluído nesta sessão (2026-09-10)

- [x] **`feat-002` fechada** (branch `feature/SV-261`, story SV-261, subtasks SV-263..267, PR #1
      merged em `develop` com CI verde). `feat-002.4` (cenário DLQ) e `feat-002.5` (evidência e
      fechamento) executados nesta sessão — `feat-002.1..3` já vinham de uma sessão anterior.
      Cenário retry (`feat-002.3`, já fechado antes): 4 mensagens acumuladas sem perda, drenadas
      corretamente ao religar `stats-service`. Cenário DLQ (`feat-002.4`, desta sessão): derrubar
      `postgres-stats` + publicar 1 evento levou a mensagem a `stats.bet-events.dlq` em ~105s (3
      tentativas de retry de aplicação, cada uma limitada pelo `connection-timeout` de 30s do
      HikariCP); registro síncrono da aposta não bloqueou.
- [x] **2 achados reais corrigidos durante o teste, ambos em outros repositórios**:
      1. RabbitMQ 4.3+ deixou de contar `nack(requeue=true)` para `x-delivery-limit` — corrigido
         em `services/stats-service` `feat-010` (retry de aplicação via `spring.rabbitmq.listener.
         simple.retry`), fechada nesta sessão (story SV-268, PR #36, CI+Sonar verdes). O cenário
         de DLQ desta sessão já rodou contra a versão corrigida.
      2. `api-gateway` nunca roteava `/api/v1/tipsters/**` (decisão deliberada de `feat-007` que
         ficou obsoleta quando `apps/web feat-008` ganhou a aba de tipsters) — corrigido em
         `services/api-gateway` `feat-008` (story SV-274, PR #27, CI+Sonar verdes).
- [x] **Achado de processo, corrigido nesta sessão**: `feat-002.1..3` (subtasks SV-263/264/265)
      tinham sido mescladas localmente numa sessão anterior sem nunca passar por PR/CI real do
      GitHub — desvio do fluxo de 2 gates deste `CLAUDE.md`. Corrigido *retroativamente* nesta
      sessão: as branches foram empurradas para o GitHub e o PR `feature/SV-261 -> develop` (o
      gate mais pesado, com `init.sh` + Delivery Reviewer já rodados) passou pela CI real antes do
      merge — documentado como desvio conhecido na descrição do PR e na evidência da feature, não
      escondido.
- [x] **Delivery Reviewer (passe próprio) sobre a evidência**: encontrou e corrigiu 2 imprecisões
      antes do commit final — uma alegação de "health 200 o tempo todo" que na verdade só foi
      verificada em 2 pontos (não monitoramento contínuo), e uma atribuição errada de qual subtask
      provisionou o tenant de teste original.
- [x] **Ambiente encerrado**: 4 processos Java parados, `docker compose down -v`, `./init.sh` da
      raiz e deste repositório verdes.
- [x] **Branches limpas**: todas as `feature/*`/`subtask/*` já mescladas em `develop` (deste
      repositório e dos outros 3 tocados nesta sessão) deletadas local e remotamente.

## Bloqueios / Riscos

- Nenhum bloqueio novo. Estratégia `at-most-once` da DLQ (`docs/DECISIONS-LOG.md` 2026-08-03)
  permanece válida — nenhum dos 2 cenários mostrou perda de mensagem.

## Próxima sessão — por onde começar

1. Rodar `./init.sh` (raiz e deste repositório) — deve sair `0`.
2. Único item `not-started` deste harness: `feat-004` (Kubernetes, fecha `epic-010` da raiz).
   Precisa de `plan_review` (Plan Reviewer) antes de virar `in-progress` — escopo grande
   (Dockerfile para os 4 serviços Java + manifests/Helm para os 6 componentes do compose atual).
3. Na raiz, `epic-007` já fecha com este trabalho — conferir se `feature_list.json` da raiz
   precisa de mais algum ajuste além de marcar `epic-007` `done`.
