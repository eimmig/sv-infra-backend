# Session Handoff — infra

> Estado atual, não histórico. O diário cronológico é o `progress.md` — este arquivo é reescrito
> a cada sessão para responder "o que a próxima sessão precisa saber agora".

**Última atualização:** 2026-09-10

## Objetivo atual

- **Todas as 4 features deste harness estão `done`** (`feat-001..004`). `epic-001`, `epic-007` e
  `epic-010` da raiz fecham com isso — **todos os 9 epics do backlog raiz estão `done`**. Nenhum
  trabalho pendente neste harness até surgir uma nova feature.

## Concluído nesta sessão (2026-09-10)

- [x] `feat-002` (resiliência DLQ/retry, fecha `epic-007`) fechada — ver entrada datada em
      `progress.md` para o detalhe completo.
- [x] `feat-004` (migração Kubernetes, fecha `epic-010`) fechada — manifests YAML puros em
      `k8s/`, validados contra um cluster `kind` local de ponta a ponta (não só `kubectl get
      pods` verde): tenant provisionado via `port-forward`, login+aposta via `Ingress` real,
      evento confirmado consumido dentro do cluster. Dockerfile de cada um dos 5 serviços de
      aplicação (4 Java + `telegram-integration`) feito como feature própria em cada
      repositório, não aqui. Ver entrada datada em `progress.md` para o detalhe completo
      (decisões de escopo, achado do SonarCloud em `telegram-integration`, etc.).

## Bloqueios / Riscos

- Nenhum.

## Próxima sessão — por onde começar

1. Rodar `./init.sh` (raiz e deste repositório) — deve sair `0`.
2. **Nenhum epic `not-started` resta na raiz.** Próximo trabalho do projeto, se houver, vem de
   fora do backlog original: gaps já conhecidos e aceitos (`apps/web feat-009`/`feat-010`, RF12/
   RF13, `not-started` naquele harness) ou nova decisão do usuário.
3. Cluster `kind` (`stakevault`) pode continuar no ar de sessões anteriores — checar com
   `kubectl get pods` antes de recriar; `kind delete cluster --name stakevault` se precisar de
   um estado limpo.
